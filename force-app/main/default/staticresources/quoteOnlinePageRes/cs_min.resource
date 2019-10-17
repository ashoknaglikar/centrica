
/** vim: et:ts=4:sw=4:sts=4
 * @license RequireJS 2.1.4 Copyright (c) 2010-2012, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/requirejs for details
 */
//Not using strict: uneven strict support in browsers, #392, and causes
//problems with requirejs.exec()/transpiler plugins that may not be strict.
/*jslint regexp: true, nomen: true, sloppy: true */
/*global window, navigator, document, importScripts, setTimeout, opera */

var requirejs, require, define;
(function (global) {
    var req, s, head, baseElement, dataMain, src,
        interactiveScript, currentlyAddingScript, mainScript, subPath,
        version = '2.1.4',
        commentRegExp = /(\/\*([\s\S]*?)\*\/|([^:]|^)\/\/(.*)$)/mg,
        cjsRequireRegExp = /[^.]\s*require\s*\(\s*["']([^'"\s]+)["']\s*\)/g,
        jsSuffixRegExp = /\.js$/,
        currDirRegExp = /^\.\//,
        op = Object.prototype,
        ostring = op.toString,
        hasOwn = op.hasOwnProperty,
        ap = Array.prototype,
        apsp = ap.splice,
        isBrowser = !!(typeof window !== 'undefined' && navigator && document),
        isWebWorker = !isBrowser && typeof importScripts !== 'undefined',
        //PS3 indicates loaded and complete, but need to wait for complete
        //specifically. Sequence is 'loading', 'loaded', execution,
        // then 'complete'. The UA check is unfortunate, but not sure how
        //to feature test w/o causing perf issues.
        readyRegExp = isBrowser && navigator.platform === 'PLAYSTATION 3' ?
                      /^complete$/ : /^(complete|loaded)$/,
        defContextName = '_',
        //Oh the tragedy, detecting opera. See the usage of isOpera for reason.
        isOpera = typeof opera !== 'undefined' && opera.toString() === '[object Opera]',
        contexts = {},
        cfg = {},
        globalDefQueue = [],
        useInteractive = false;

    function isFunction(it) {
        return ostring.call(it) === '[object Function]';
    }

    function isArray(it) {
        return ostring.call(it) === '[object Array]';
    }

    /**
     * Helper function for iterating over an array. If the func returns
     * a true value, it will break out of the loop.
     */
    function each(ary, func) {
        if (ary) {
            var i;
            for (i = 0; i < ary.length; i += 1) {
                if (ary[i] && func(ary[i], i, ary)) {
                    break;
                }
            }
        }
    }

    /**
     * Helper function for iterating over an array backwards. If the func
     * returns a true value, it will break out of the loop.
     */
    function eachReverse(ary, func) {
        if (ary) {
            var i;
            for (i = ary.length - 1; i > -1; i -= 1) {
                if (ary[i] && func(ary[i], i, ary)) {
                    break;
                }
            }
        }
    }

    function hasProp(obj, prop) {
        return hasOwn.call(obj, prop);
    }

    function getOwn(obj, prop) {
        return hasProp(obj, prop) && obj[prop];
    }

    /**
     * Cycles over properties in an object and calls a function for each
     * property value. If the function returns a truthy value, then the
     * iteration is stopped.
     */
    function eachProp(obj, func) {
        var prop;
        for (prop in obj) {
            if (hasProp(obj, prop)) {
                if (func(obj[prop], prop)) {
                    break;
                }
            }
        }
    }

    /**
     * Simple function to mix in properties from source into target,
     * but only if target does not already have a property of the same name.
     */
    function mixin(target, source, force, deepStringMixin) {
        if (source) {
            eachProp(source, function (value, prop) {
                if (force || !hasProp(target, prop)) {
                    if (deepStringMixin && typeof value !== 'string') {
                        if (!target[prop]) {
                            target[prop] = {};
                        }
                        mixin(target[prop], value, force, deepStringMixin);
                    } else {
                        target[prop] = value;
                    }
                }
            });
        }
        return target;
    }

    //Similar to Function.prototype.bind, but the 'this' object is specified
    //first, since it is easier to read/figure out what 'this' will be.
    function bind(obj, fn) {
        return function () {
            return fn.apply(obj, arguments);
        };
    }

    function scripts() {
        return document.getElementsByTagName('script');
    }

    //Allow getting a global that expressed in
    //dot notation, like 'a.b.c'.
    function getGlobal(value) {
        if (!value) {
            return value;
        }
        var g = global;
        each(value.split('.'), function (part) {
            g = g[part];
        });
        return g;
    }

    /**
     * Constructs an error with a pointer to an URL with more information.
     * @param {String} id the error ID that maps to an ID on a web page.
     * @param {String} message human readable error.
     * @param {Error} [err] the original error, if there is one.
     *
     * @returns {Error}
     */
    function makeError(id, msg, err, requireModules) {
        var e = new Error(msg + '\nhttp://requirejs.org/docs/errors.html#' + id);
        e.requireType = id;
        e.requireModules = requireModules;
        if (err) {
            e.originalError = err;
        }
        return e;
    }

    if (typeof define !== 'undefined') {
        //If a define is already in play via another AMD loader,
        //do not overwrite.
        return;
    }

    if (typeof requirejs !== 'undefined') {
        if (isFunction(requirejs)) {
            //Do not overwrite and existing requirejs instance.
            return;
        }
        cfg = requirejs;
        requirejs = undefined;
    }

    //Allow for a require config object
    if (typeof require !== 'undefined' && !isFunction(require)) {
        //assume it is a config object.
        cfg = require;
        require = undefined;
    }

    function newContext(contextName) {
        var inCheckLoaded, Module, context, handlers,
            checkLoadedTimeoutId,
            config = {
                waitSeconds: 7,
                baseUrl: './',
                paths: {},
                pkgs: {},
                shim: {},
                map: {},
                config: {}
            },
            registry = {},
            undefEvents = {},
            defQueue = [],
            defined = {},
            urlFetched = {},
            requireCounter = 1,
            unnormalizedCounter = 1;

        /**
         * Trims the . and .. from an array of path segments.
         * It will keep a leading path segment if a .. will become
         * the first path segment, to help with module name lookups,
         * which act like paths, but can be remapped. But the end result,
         * all paths that use this function should look normalized.
         * NOTE: this method MODIFIES the input array.
         * @param {Array} ary the array of path segments.
         */
        function trimDots(ary) {
            var i, part;
            for (i = 0; ary[i]; i += 1) {
                part = ary[i];
                if (part === '.') {
                    ary.splice(i, 1);
                    i -= 1;
                } else if (part === '..') {
                    if (i === 1 && (ary[2] === '..' || ary[0] === '..')) {
                        //End of the line. Keep at least one non-dot
                        //path segment at the front so it can be mapped
                        //correctly to disk. Otherwise, there is likely
                        //no path mapping for a path starting with '..'.
                        //This can still fail, but catches the most reasonable
                        //uses of ..
                        break;
                    } else if (i > 0) {
                        ary.splice(i - 1, 2);
                        i -= 2;
                    }
                }
            }
        }

        /**
         * Given a relative module name, like ./something, normalize it to
         * a real name that can be mapped to a path.
         * @param {String} name the relative name
         * @param {String} baseName a real name that the name arg is relative
         * to.
         * @param {Boolean} applyMap apply the map config to the value. Should
         * only be done if this normalization is for a dependency ID.
         * @returns {String} normalized name
         */
        function normalize(name, baseName, applyMap) {
            var pkgName, pkgConfig, mapValue, nameParts, i, j, nameSegment,
                foundMap, foundI, foundStarMap, starI,
                baseParts = baseName && baseName.split('/'),
                normalizedBaseParts = baseParts,
                map = config.map,
                starMap = map && map['*'];

            //Adjust any relative paths.
            if (name && name.charAt(0) === '.') {
                //If have a base name, try to normalize against it,
                //otherwise, assume it is a top-level require that will
                //be relative to baseUrl in the end.
                if (baseName) {
                    if (getOwn(config.pkgs, baseName)) {
                        //If the baseName is a package name, then just treat it as one
                        //name to concat the name with.
                        normalizedBaseParts = baseParts = [baseName];
                    } else {
                        //Convert baseName to array, and lop off the last part,
                        //so that . matches that 'directory' and not name of the baseName's
                        //module. For instance, baseName of 'one/two/three', maps to
                        //'one/two/three.js', but we want the directory, 'one/two' for
                        //this normalization.
                        normalizedBaseParts = baseParts.slice(0, baseParts.length - 1);
                    }

                    name = normalizedBaseParts.concat(name.split('/'));
                    trimDots(name);

                    //Some use of packages may use a . path to reference the
                    //'main' module name, so normalize for that.
                    pkgConfig = getOwn(config.pkgs, (pkgName = name[0]));
                    name = name.join('/');
                    if (pkgConfig && name === pkgName + '/' + pkgConfig.main) {
                        name = pkgName;
                    }
                } else if (name.indexOf('./') === 0) {
                    // No baseName, so this is ID is resolved relative
                    // to baseUrl, pull off the leading dot.
                    name = name.substring(2);
                }
            }

            //Apply map config if available.
            if (applyMap && (baseParts || starMap) && map) {
                nameParts = name.split('/');

                for (i = nameParts.length; i > 0; i -= 1) {
                    nameSegment = nameParts.slice(0, i).join('/');

                    if (baseParts) {
                        //Find the longest baseName segment match in the config.
                        //So, do joins on the biggest to smallest lengths of baseParts.
                        for (j = baseParts.length; j > 0; j -= 1) {
                            mapValue = getOwn(map, baseParts.slice(0, j).join('/'));

                            //baseName segment has config, find if it has one for
                            //this name.
                            if (mapValue) {
                                mapValue = getOwn(mapValue, nameSegment);
                                if (mapValue) {
                                    //Match, update name to the new value.
                                    foundMap = mapValue;
                                    foundI = i;
                                    break;
                                }
                            }
                        }
                    }

                    if (foundMap) {
                        break;
                    }

                    //Check for a star map match, but just hold on to it,
                    //if there is a shorter segment match later in a matching
                    //config, then favor over this star map.
                    if (!foundStarMap && starMap && getOwn(starMap, nameSegment)) {
                        foundStarMap = getOwn(starMap, nameSegment);
                        starI = i;
                    }
                }

                if (!foundMap && foundStarMap) {
                    foundMap = foundStarMap;
                    foundI = starI;
                }

                if (foundMap) {
                    nameParts.splice(0, foundI, foundMap);
                    name = nameParts.join('/');
                }
            }

            return name;
        }

        function removeScript(name) {
            if (isBrowser) {
                each(scripts(), function (scriptNode) {
                    if (scriptNode.getAttribute('data-requiremodule') === name &&
                            scriptNode.getAttribute('data-requirecontext') === context.contextName) {
                        scriptNode.parentNode.removeChild(scriptNode);
                        return true;
                    }
                });
            }
        }

        function hasPathFallback(id) {
            var pathConfig = getOwn(config.paths, id);
            if (pathConfig && isArray(pathConfig) && pathConfig.length > 1) {
                removeScript(id);
                //Pop off the first array value, since it failed, and
                //retry
                pathConfig.shift();
                context.require.undef(id);
                context.require([id]);
                return true;
            }
        }

        //Turns a plugin!resource to [plugin, resource]
        //with the plugin being undefined if the name
        //did not have a plugin prefix.
        function splitPrefix(name) {
            var prefix,
                index = name ? name.indexOf('!') : -1;
            if (index > -1) {
                prefix = name.substring(0, index);
                name = name.substring(index + 1, name.length);
            }
            return [prefix, name];
        }

        /**
         * Creates a module mapping that includes plugin prefix, module
         * name, and path. If parentModuleMap is provided it will
         * also normalize the name via require.normalize()
         *
         * @param {String} name the module name
         * @param {String} [parentModuleMap] parent module map
         * for the module name, used to resolve relative names.
         * @param {Boolean} isNormalized: is the ID already normalized.
         * This is true if this call is done for a define() module ID.
         * @param {Boolean} applyMap: apply the map config to the ID.
         * Should only be true if this map is for a dependency.
         *
         * @returns {Object}
         */
        function makeModuleMap(name, parentModuleMap, isNormalized, applyMap) {
            var url, pluginModule, suffix, nameParts,
                prefix = null,
                parentName = parentModuleMap ? parentModuleMap.name : null,
                originalName = name,
                isDefine = true,
                normalizedName = '';

            //If no name, then it means it is a require call, generate an
            //internal name.
            if (!name) {
                isDefine = false;
                name = '_@r' + (requireCounter += 1);
            }

            nameParts = splitPrefix(name);
            prefix = nameParts[0];
            name = nameParts[1];

            if (prefix) {
                prefix = normalize(prefix, parentName, applyMap);
                pluginModule = getOwn(defined, prefix);
            }

            //Account for relative paths if there is a base name.
            if (name) {
                if (prefix) {
                    if (pluginModule && pluginModule.normalize) {
                        //Plugin is loaded, use its normalize method.
                        normalizedName = pluginModule.normalize(name, function (name) {
                            return normalize(name, parentName, applyMap);
                        });
                    } else {
                        normalizedName = normalize(name, parentName, applyMap);
                    }
                } else {
                    //A regular module.
                    normalizedName = normalize(name, parentName, applyMap);

                    //Normalized name may be a plugin ID due to map config
                    //application in normalize. The map config values must
                    //already be normalized, so do not need to redo that part.
                    nameParts = splitPrefix(normalizedName);
                    prefix = nameParts[0];
                    normalizedName = nameParts[1];
                    isNormalized = true;

                    url = context.nameToUrl(normalizedName);
                }
            }

            //If the id is a plugin id that cannot be determined if it needs
            //normalization, stamp it with a unique ID so two matching relative
            //ids that may conflict can be separate.
            suffix = prefix && !pluginModule && !isNormalized ?
                     '_unnormalized' + (unnormalizedCounter += 1) :
                     '';

            return {
                prefix: prefix,
                name: normalizedName,
                parentMap: parentModuleMap,
                unnormalized: !!suffix,
                url: url,
                originalName: originalName,
                isDefine: isDefine,
                id: (prefix ?
                        prefix + '!' + normalizedName :
                        normalizedName) + suffix
            };
        }

        function getModule(depMap) {
            var id = depMap.id,
                mod = getOwn(registry, id);

            if (!mod) {
                mod = registry[id] = new context.Module(depMap);
            }

            return mod;
        }

        function on(depMap, name, fn) {
            var id = depMap.id,
                mod = getOwn(registry, id);

            if (hasProp(defined, id) &&
                    (!mod || mod.defineEmitComplete)) {
                if (name === 'defined') {
                    fn(defined[id]);
                }
            } else {
                getModule(depMap).on(name, fn);
            }
        }

        function onError(err, errback) {
            var ids = err.requireModules,
                notified = false;

            if (errback) {
                errback(err);
            } else {
                each(ids, function (id) {
                    var mod = getOwn(registry, id);
                    if (mod) {
                        //Set error on module, so it skips timeout checks.
                        mod.error = err;
                        if (mod.events.error) {
                            notified = true;
                            mod.emit('error', err);
                        }
                    }
                });

                if (!notified) {
                    req.onError(err);
                }
            }
        }

        /**
         * Internal method to transfer globalQueue items to this context's
         * defQueue.
         */
        function takeGlobalQueue() {
            //Push all the globalDefQueue items into the context's defQueue
            if (globalDefQueue.length) {
                //Array splice in the values since the context code has a
                //local var ref to defQueue, so cannot just reassign the one
                //on context.
                apsp.apply(defQueue,
                           [defQueue.length - 1, 0].concat(globalDefQueue));
                globalDefQueue = [];
            }
        }

        handlers = {
            'require': function (mod) {
                if (mod.require) {
                    return mod.require;
                } else {
                    return (mod.require = context.makeRequire(mod.map));
                }
            },
            'exports': function (mod) {
                mod.usingExports = true;
                if (mod.map.isDefine) {
                    if (mod.exports) {
                        return mod.exports;
                    } else {
                        return (mod.exports = defined[mod.map.id] = {});
                    }
                }
            },
            'module': function (mod) {
                if (mod.module) {
                    return mod.module;
                } else {
                    return (mod.module = {
                        id: mod.map.id,
                        uri: mod.map.url,
                        config: function () {
                            return (config.config && getOwn(config.config, mod.map.id)) || {};
                        },
                        exports: defined[mod.map.id]
                    });
                }
            }
        };

        function cleanRegistry(id) {
            //Clean up machinery used for waiting modules.
            delete registry[id];
        }

        function breakCycle(mod, traced, processed) {
            var id = mod.map.id;

            if (mod.error) {
                mod.emit('error', mod.error);
            } else {
                traced[id] = true;
                each(mod.depMaps, function (depMap, i) {
                    var depId = depMap.id,
                        dep = getOwn(registry, depId);

                    //Only force things that have not completed
                    //being defined, so still in the registry,
                    //and only if it has not been matched up
                    //in the module already.
                    if (dep && !mod.depMatched[i] && !processed[depId]) {
                        if (getOwn(traced, depId)) {
                            mod.defineDep(i, defined[depId]);
                            mod.check(); //pass false?
                        } else {
                            breakCycle(dep, traced, processed);
                        }
                    }
                });
                processed[id] = true;
            }
        }

        function checkLoaded() {
            var map, modId, err, usingPathFallback,
                waitInterval = config.waitSeconds * 1000,
                //It is possible to disable the wait interval by using waitSeconds of 0.
                expired = waitInterval && (context.startTime + waitInterval) < new Date().getTime(),
                noLoads = [],
                reqCalls = [],
                stillLoading = false,
                needCycleCheck = true;

            //Do not bother if this call was a result of a cycle break.
            if (inCheckLoaded) {
                return;
            }

            inCheckLoaded = true;

            //Figure out the state of all the modules.
            eachProp(registry, function (mod) {
                map = mod.map;
                modId = map.id;

                //Skip things that are not enabled or in error state.
                if (!mod.enabled) {
                    return;
                }

                if (!map.isDefine) {
                    reqCalls.push(mod);
                }

                if (!mod.error) {
                    //If the module should be executed, and it has not
                    //been inited and time is up, remember it.
                    if (!mod.inited && expired) {
                        if (hasPathFallback(modId)) {
                            usingPathFallback = true;
                            stillLoading = true;
                        } else {
                            noLoads.push(modId);
                            removeScript(modId);
                        }
                    } else if (!mod.inited && mod.fetched && map.isDefine) {
                        stillLoading = true;
                        if (!map.prefix) {
                            //No reason to keep looking for unfinished
                            //loading. If the only stillLoading is a
                            //plugin resource though, keep going,
                            //because it may be that a plugin resource
                            //is waiting on a non-plugin cycle.
                            return (needCycleCheck = false);
                        }
                    }
                }
            });

            if (expired && noLoads.length) {
                //If wait time expired, throw error of unloaded modules.
                err = makeError('timeout', 'Load timeout for modules: ' + noLoads, null, noLoads);
                err.contextName = context.contextName;
                return onError(err);
            }

            //Not expired, check for a cycle.
            if (needCycleCheck) {
                each(reqCalls, function (mod) {
                    breakCycle(mod, {}, {});
                });
            }

            //If still waiting on loads, and the waiting load is something
            //other than a plugin resource, or there are still outstanding
            //scripts, then just try back later.
            if ((!expired || usingPathFallback) && stillLoading) {
                //Something is still waiting to load. Wait for it, but only
                //if a timeout is not already in effect.
                if ((isBrowser || isWebWorker) && !checkLoadedTimeoutId) {
                    checkLoadedTimeoutId = setTimeout(function () {
                        checkLoadedTimeoutId = 0;
                        checkLoaded();
                    }, 50);
                }
            }

            inCheckLoaded = false;
        }

        Module = function (map) {
            this.events = getOwn(undefEvents, map.id) || {};
            this.map = map;
            this.shim = getOwn(config.shim, map.id);
            this.depExports = [];
            this.depMaps = [];
            this.depMatched = [];
            this.pluginMaps = {};
            this.depCount = 0;

            /* this.exports this.factory
               this.depMaps = [],
               this.enabled, this.fetched
            */
        };

        Module.prototype = {
            init: function (depMaps, factory, errback, options) {
                options = options || {};

                //Do not do more inits if already done. Can happen if there
                //are multiple define calls for the same module. That is not
                //a normal, common case, but it is also not unexpected.
                if (this.inited) {
                    return;
                }

                this.factory = factory;

                if (errback) {
                    //Register for errors on this module.
                    this.on('error', errback);
                } else if (this.events.error) {
                    //If no errback already, but there are error listeners
                    //on this module, set up an errback to pass to the deps.
                    errback = bind(this, function (err) {
                        this.emit('error', err);
                    });
                }

                //Do a copy of the dependency array, so that
                //source inputs are not modified. For example
                //"shim" deps are passed in here directly, and
                //doing a direct modification of the depMaps array
                //would affect that config.
                this.depMaps = depMaps && depMaps.slice(0);

                this.errback = errback;

                //Indicate this module has be initialized
                this.inited = true;

                this.ignore = options.ignore;

                //Could have option to init this module in enabled mode,
                //or could have been previously marked as enabled. However,
                //the dependencies are not known until init is called. So
                //if enabled previously, now trigger dependencies as enabled.
                if (options.enabled || this.enabled) {
                    //Enable this module and dependencies.
                    //Will call this.check()
                    this.enable();
                } else {
                    this.check();
                }
            },

            defineDep: function (i, depExports) {
                //Because of cycles, defined callback for a given
                //export can be called more than once.
                if (!this.depMatched[i]) {
                    this.depMatched[i] = true;
                    this.depCount -= 1;
                    this.depExports[i] = depExports;
                }
            },

            fetch: function () {
                if (this.fetched) {
                    return;
                }
                this.fetched = true;

                context.startTime = (new Date()).getTime();

                var map = this.map;

                //If the manager is for a plugin managed resource,
                //ask the plugin to load it now.
                if (this.shim) {
                    context.makeRequire(this.map, {
                        enableBuildCallback: true
                    })(this.shim.deps || [], bind(this, function () {
                        return map.prefix ? this.callPlugin() : this.load();
                    }));
                } else {
                    //Regular dependency.
                    return map.prefix ? this.callPlugin() : this.load();
                }
            },

            load: function () {
                var url = this.map.url;

                //Regular dependency.
                if (!urlFetched[url]) {
                    urlFetched[url] = true;
                    context.load(this.map.id, url);
                }
            },

            /**
             * Checks is the module is ready to define itself, and if so,
             * define it.
             */
            check: function () {
                if (!this.enabled || this.enabling) {
                    return;
                }

                var err, cjsModule,
                    id = this.map.id,
                    depExports = this.depExports,
                    exports = this.exports,
                    factory = this.factory;

                if (!this.inited) {
                    this.fetch();
                } else if (this.error) {
                    this.emit('error', this.error);
                } else if (!this.defining) {
                    //The factory could trigger another require call
                    //that would result in checking this module to
                    //define itself again. If already in the process
                    //of doing that, skip this work.
                    this.defining = true;

                    if (this.depCount < 1 && !this.defined) {
                        if (isFunction(factory)) {
                            //If there is an error listener, favor passing
                            //to that instead of throwing an error.
                            if (this.events.error) {
                                try {
                                    exports = context.execCb(id, factory, depExports, exports);
                                } catch (e) {
                                    err = e;
                                }
                            } else {
                                exports = context.execCb(id, factory, depExports, exports);
                            }

                            if (this.map.isDefine) {
                                //If setting exports via 'module' is in play,
                                //favor that over return value and exports. After that,
                                //favor a non-undefined return value over exports use.
                                cjsModule = this.module;
                                if (cjsModule &&
                                        cjsModule.exports !== undefined &&
                                        //Make sure it is not already the exports value
                                        cjsModule.exports !== this.exports) {
                                    exports = cjsModule.exports;
                                } else if (exports === undefined && this.usingExports) {
                                    //exports already set the defined value.
                                    exports = this.exports;
                                }
                            }

                            if (err) {
                                err.requireMap = this.map;
                                err.requireModules = [this.map.id];
                                err.requireType = 'define';
                                return onError((this.error = err));
                            }

                        } else {
                            //Just a literal value
                            exports = factory;
                        }

                        this.exports = exports;

                        if (this.map.isDefine && !this.ignore) {
                            defined[id] = exports;

                            if (req.onResourceLoad) {
                                req.onResourceLoad(context, this.map, this.depMaps);
                            }
                        }

                        //Clean up
                        delete registry[id];

                        this.defined = true;
                    }

                    //Finished the define stage. Allow calling check again
                    //to allow define notifications below in the case of a
                    //cycle.
                    this.defining = false;

                    if (this.defined && !this.defineEmitted) {
                        this.defineEmitted = true;
                        this.emit('defined', this.exports);
                        this.defineEmitComplete = true;
                    }

                }
            },

            callPlugin: function () {
                var map = this.map,
                    id = map.id,
                    //Map already normalized the prefix.
                    pluginMap = makeModuleMap(map.prefix);

                //Mark this as a dependency for this plugin, so it
                //can be traced for cycles.
                this.depMaps.push(pluginMap);

                on(pluginMap, 'defined', bind(this, function (plugin) {
                    var load, normalizedMap, normalizedMod,
                        name = this.map.name,
                        parentName = this.map.parentMap ? this.map.parentMap.name : null,
                        localRequire = context.makeRequire(map.parentMap, {
                            enableBuildCallback: true
                        });

                    //If current map is not normalized, wait for that
                    //normalized name to load instead of continuing.
                    if (this.map.unnormalized) {
                        //Normalize the ID if the plugin allows it.
                        if (plugin.normalize) {
                            name = plugin.normalize(name, function (name) {
                                return normalize(name, parentName, true);
                            }) || '';
                        }

                        //prefix and name should already be normalized, no need
                        //for applying map config again either.
                        normalizedMap = makeModuleMap(map.prefix + '!' + name,
                                                      this.map.parentMap);
                        on(normalizedMap,
                            'defined', bind(this, function (value) {
                                this.init([], function () { return value; }, null, {
                                    enabled: true,
                                    ignore: true
                                });
                            }));

                        normalizedMod = getOwn(registry, normalizedMap.id);
                        if (normalizedMod) {
                            //Mark this as a dependency for this plugin, so it
                            //can be traced for cycles.
                            this.depMaps.push(normalizedMap);

                            if (this.events.error) {
                                normalizedMod.on('error', bind(this, function (err) {
                                    this.emit('error', err);
                                }));
                            }
                            normalizedMod.enable();
                        }

                        return;
                    }

                    load = bind(this, function (value) {
                        this.init([], function () { return value; }, null, {
                            enabled: true
                        });
                    });

                    load.error = bind(this, function (err) {
                        this.inited = true;
                        this.error = err;
                        err.requireModules = [id];

                        //Remove temp unnormalized modules for this module,
                        //since they will never be resolved otherwise now.
                        eachProp(registry, function (mod) {
                            if (mod.map.id.indexOf(id + '_unnormalized') === 0) {
                                cleanRegistry(mod.map.id);
                            }
                        });

                        onError(err);
                    });

                    //Allow plugins to load other code without having to know the
                    //context or how to 'complete' the load.
                    load.fromText = bind(this, function (text, textAlt) {
                        /*jslint evil: true */
                        var moduleName = map.name,
                            moduleMap = makeModuleMap(moduleName),
                            hasInteractive = useInteractive;

                        //As of 2.1.0, support just passing the text, to reinforce
                        //fromText only being called once per resource. Still
                        //support old style of passing moduleName but discard
                        //that moduleName in favor of the internal ref.
                        if (textAlt) {
                            text = textAlt;
                        }

                        //Turn off interactive script matching for IE for any define
                        //calls in the text, then turn it back on at the end.
                        if (hasInteractive) {
                            useInteractive = false;
                        }

                        //Prime the system by creating a module instance for
                        //it.
                        getModule(moduleMap);

                        //Transfer any config to this other module.
                        if (hasProp(config.config, id)) {
                            config.config[moduleName] = config.config[id];
                        }

                        try {
                            req.exec(text);
                        } catch (e) {
                            return onError(makeError('fromtexteval',
                                             'fromText eval for ' + id +
                                            ' failed: ' + e,
                                             e,
                                             [id]));
                        }

                        if (hasInteractive) {
                            useInteractive = true;
                        }

                        //Mark this as a dependency for the plugin
                        //resource
                        this.depMaps.push(moduleMap);

                        //Support anonymous modules.
                        context.completeLoad(moduleName);

                        //Bind the value of that module to the value for this
                        //resource ID.
                        localRequire([moduleName], load);
                    });

                    //Use parentName here since the plugin's name is not reliable,
                    //could be some weird string with no path that actually wants to
                    //reference the parentName's path.
                    plugin.load(map.name, localRequire, load, config);
                }));

                context.enable(pluginMap, this);
                this.pluginMaps[pluginMap.id] = pluginMap;
            },

            enable: function () {
                this.enabled = true;

                //Set flag mentioning that the module is enabling,
                //so that immediate calls to the defined callbacks
                //for dependencies do not trigger inadvertent load
                //with the depCount still being zero.
                this.enabling = true;

                //Enable each dependency
                each(this.depMaps, bind(this, function (depMap, i) {
                    var id, mod, handler;

                    if (typeof depMap === 'string') {
                        //Dependency needs to be converted to a depMap
                        //and wired up to this module.
                        depMap = makeModuleMap(depMap,
                                               (this.map.isDefine ? this.map : this.map.parentMap),
                                               false,
                                               !this.skipMap);
                        this.depMaps[i] = depMap;

                        handler = getOwn(handlers, depMap.id);

                        if (handler) {
                            this.depExports[i] = handler(this);
                            return;
                        }

                        this.depCount += 1;

                        on(depMap, 'defined', bind(this, function (depExports) {
                            this.defineDep(i, depExports);
                            this.check();
                        }));

                        if (this.errback) {
                            on(depMap, 'error', this.errback);
                        }
                    }

                    id = depMap.id;
                    mod = registry[id];

                    //Skip special modules like 'require', 'exports', 'module'
                    //Also, don't call enable if it is already enabled,
                    //important in circular dependency cases.
                    if (!hasProp(handlers, id) && mod && !mod.enabled) {
                        context.enable(depMap, this);
                    }
                }));

                //Enable each plugin that is used in
                //a dependency
                eachProp(this.pluginMaps, bind(this, function (pluginMap) {
                    var mod = getOwn(registry, pluginMap.id);
                    if (mod && !mod.enabled) {
                        context.enable(pluginMap, this);
                    }
                }));

                this.enabling = false;

                this.check();
            },

            on: function (name, cb) {
                var cbs = this.events[name];
                if (!cbs) {
                    cbs = this.events[name] = [];
                }
                cbs.push(cb);
            },

            emit: function (name, evt) {
                each(this.events[name], function (cb) {
                    cb(evt);
                });
                if (name === 'error') {
                    //Now that the error handler was triggered, remove
                    //the listeners, since this broken Module instance
                    //can stay around for a while in the registry.
                    delete this.events[name];
                }
            }
        };

        function callGetModule(args) {
            //Skip modules already defined.
            if (!hasProp(defined, args[0])) {
                getModule(makeModuleMap(args[0], null, true)).init(args[1], args[2]);
            }
        }

        function removeListener(node, func, name, ieName) {
            //Favor detachEvent because of IE9
            //issue, see attachEvent/addEventListener comment elsewhere
            //in this file.
            if (node.detachEvent && !isOpera) {
                //Probably IE. If not it will throw an error, which will be
                //useful to know.
                if (ieName) {
                    node.detachEvent(ieName, func);
                }
            } else {
                node.removeEventListener(name, func, false);
            }
        }

        /**
         * Given an event from a script node, get the requirejs info from it,
         * and then removes the event listeners on the node.
         * @param {Event} evt
         * @returns {Object}
         */
        function getScriptData(evt) {
            //Using currentTarget instead of target for Firefox 2.0's sake. Not
            //all old browsers will be supported, but this one was easy enough
            //to support and still makes sense.
            var node = evt.currentTarget || evt.srcElement;

            //Remove the listeners once here.
            removeListener(node, context.onScriptLoad, 'load', 'onreadystatechange');
            removeListener(node, context.onScriptError, 'error');

            return {
                node: node,
                id: node && node.getAttribute('data-requiremodule')
            };
        }

        function intakeDefines() {
            var args;

            //Any defined modules in the global queue, intake them now.
            takeGlobalQueue();

            //Make sure any remaining defQueue items get properly processed.
            while (defQueue.length) {
                args = defQueue.shift();
                if (args[0] === null) {
                    return onError(makeError('mismatch', 'Mismatched anonymous define() module: ' + args[args.length - 1]));
                } else {
                    //args are id, deps, factory. Should be normalized by the
                    //define() function.
                    callGetModule(args);
                }
            }
        }

        context = {
            config: config,
            contextName: contextName,
            registry: registry,
            defined: defined,
            urlFetched: urlFetched,
            defQueue: defQueue,
            Module: Module,
            makeModuleMap: makeModuleMap,
            nextTick: req.nextTick,

            /**
             * Set a configuration for the context.
             * @param {Object} cfg config object to integrate.
             */
            configure: function (cfg) {
                //Make sure the baseUrl ends in a slash.
                if (cfg.baseUrl) {
                    if (cfg.baseUrl.charAt(cfg.baseUrl.length - 1) !== '/') {
                        cfg.baseUrl += '/';
                    }
                }

                //Save off the paths and packages since they require special processing,
                //they are additive.
                var pkgs = config.pkgs,
                    shim = config.shim,
                    objs = {
                        paths: true,
                        config: true,
                        map: true
                    };

                eachProp(cfg, function (value, prop) {
                    if (objs[prop]) {
                        if (prop === 'map') {
                            mixin(config[prop], value, true, true);
                        } else {
                            mixin(config[prop], value, true);
                        }
                    } else {
                        config[prop] = value;
                    }
                });

                //Merge shim
                if (cfg.shim) {
                    eachProp(cfg.shim, function (value, id) {
                        //Normalize the structure
                        if (isArray(value)) {
                            value = {
                                deps: value
                            };
                        }
                        if ((value.exports || value.init) && !value.exportsFn) {
                            value.exportsFn = context.makeShimExports(value);
                        }
                        shim[id] = value;
                    });
                    config.shim = shim;
                }

                //Adjust packages if necessary.
                if (cfg.packages) {
                    each(cfg.packages, function (pkgObj) {
                        var location;

                        pkgObj = typeof pkgObj === 'string' ? { name: pkgObj } : pkgObj;
                        location = pkgObj.location;

                        //Create a brand new object on pkgs, since currentPackages can
                        //be passed in again, and config.pkgs is the internal transformed
                        //state for all package configs.
                        pkgs[pkgObj.name] = {
                            name: pkgObj.name,
                            location: location || pkgObj.name,
                            //Remove leading dot in main, so main paths are normalized,
                            //and remove any trailing .js, since different package
                            //envs have different conventions: some use a module name,
                            //some use a file name.
                            main: (pkgObj.main || 'main')
                                  .replace(currDirRegExp, '')
                                  .replace(jsSuffixRegExp, '')
                        };
                    });

                    //Done with modifications, assing packages back to context config
                    config.pkgs = pkgs;
                }

                //If there are any "waiting to execute" modules in the registry,
                //update the maps for them, since their info, like URLs to load,
                //may have changed.
                eachProp(registry, function (mod, id) {
                    //If module already has init called, since it is too
                    //late to modify them, and ignore unnormalized ones
                    //since they are transient.
                    if (!mod.inited && !mod.map.unnormalized) {
                        mod.map = makeModuleMap(id);
                    }
                });

                //If a deps array or a config callback is specified, then call
                //require with those args. This is useful when require is defined as a
                //config object before require.js is loaded.
                if (cfg.deps || cfg.callback) {
                    context.require(cfg.deps || [], cfg.callback);
                }
            },

            makeShimExports: function (value) {
                function fn() {
                    var ret;
                    if (value.init) {
                        ret = value.init.apply(global, arguments);
                    }
                    return ret || (value.exports && getGlobal(value.exports));
                }
                return fn;
            },

            makeRequire: function (relMap, options) {
                options = options || {};

                function localRequire(deps, callback, errback) {
                    var id, map, requireMod;

                    if (options.enableBuildCallback && callback && isFunction(callback)) {
                        callback.__requireJsBuild = true;
                    }

                    if (typeof deps === 'string') {
                        if (isFunction(callback)) {
                            //Invalid call
                            return onError(makeError('requireargs', 'Invalid require call'), errback);
                        }

                        //If require|exports|module are requested, get the
                        //value for them from the special handlers. Caveat:
                        //this only works while module is being defined.
                        if (relMap && hasProp(handlers, deps)) {
                            return handlers[deps](registry[relMap.id]);
                        }

                        //Synchronous access to one module. If require.get is
                        //available (as in the Node adapter), prefer that.
                        if (req.get) {
                            return req.get(context, deps, relMap);
                        }

                        //Normalize module name, if it contains . or ..
                        map = makeModuleMap(deps, relMap, false, true);
                        id = map.id;

                        if (!hasProp(defined, id)) {
                            return onError(makeError('notloaded', 'Module name "' +
                                        id +
                                        '" has not been loaded yet for context: ' +
                                        contextName +
                                        (relMap ? '' : '. Use require([])')));
                        }
                        return defined[id];
                    }

                    //Grab defines waiting in the global queue.
                    intakeDefines();

                    //Mark all the dependencies as needing to be loaded.
                    context.nextTick(function () {
                        //Some defines could have been added since the
                        //require call, collect them.
                        intakeDefines();

                        requireMod = getModule(makeModuleMap(null, relMap));

                        //Store if map config should be applied to this require
                        //call for dependencies.
                        requireMod.skipMap = options.skipMap;

                        requireMod.init(deps, callback, errback, {
                            enabled: true
                        });

                        checkLoaded();
                    });

                    return localRequire;
                }

                mixin(localRequire, {
                    isBrowser: isBrowser,

                    /**
                     * Converts a module name + .extension into an URL path.
                     * *Requires* the use of a module name. It does not support using
                     * plain URLs like nameToUrl.
                     */
                    toUrl: function (moduleNamePlusExt) {
                        var ext, url,
                            index = moduleNamePlusExt.lastIndexOf('.'),
                            segment = moduleNamePlusExt.split('/')[0],
                            isRelative = segment === '.' || segment === '..';

                        //Have a file extension alias, and it is not the
                        //dots from a relative path.
                        if (index !== -1 && (!isRelative || index > 1)) {
                            ext = moduleNamePlusExt.substring(index, moduleNamePlusExt.length);
                            moduleNamePlusExt = moduleNamePlusExt.substring(0, index);
                        }

                        url = context.nameToUrl(normalize(moduleNamePlusExt,
                                                relMap && relMap.id, true), ext || '.fake');
                        return ext ? url : url.substring(0, url.length - 5);
                    },

                    defined: function (id) {
                        return hasProp(defined, makeModuleMap(id, relMap, false, true).id);
                    },

                    specified: function (id) {
                        id = makeModuleMap(id, relMap, false, true).id;
                        return hasProp(defined, id) || hasProp(registry, id);
                    }
                });

                //Only allow undef on top level require calls
                if (!relMap) {
                    localRequire.undef = function (id) {
                        //Bind any waiting define() calls to this context,
                        //fix for #408
                        takeGlobalQueue();

                        var map = makeModuleMap(id, relMap, true),
                            mod = getOwn(registry, id);

                        delete defined[id];
                        delete urlFetched[map.url];
                        delete undefEvents[id];

                        if (mod) {
                            //Hold on to listeners in case the
                            //module will be attempted to be reloaded
                            //using a different config.
                            if (mod.events.defined) {
                                undefEvents[id] = mod.events;
                            }

                            cleanRegistry(id);
                        }
                    };
                }

                return localRequire;
            },

            /**
             * Called to enable a module if it is still in the registry
             * awaiting enablement. A second arg, parent, the parent module,
             * is passed in for context, when this method is overriden by
             * the optimizer. Not shown here to keep code compact.
             */
            enable: function (depMap) {
                var mod = getOwn(registry, depMap.id);
                if (mod) {
                    getModule(depMap).enable();
                }
            },

            /**
             * Internal method used by environment adapters to complete a load event.
             * A load event could be a script load or just a load pass from a synchronous
             * load call.
             * @param {String} moduleName the name of the module to potentially complete.
             */
            completeLoad: function (moduleName) {
                var found, args, mod,
                    shim = getOwn(config.shim, moduleName) || {},
                    shExports = shim.exports;

                takeGlobalQueue();

                while (defQueue.length) {
                    args = defQueue.shift();
                    if (args[0] === null) {
                        args[0] = moduleName;
                        //If already found an anonymous module and bound it
                        //to this name, then this is some other anon module
                        //waiting for its completeLoad to fire.
                        if (found) {
                            break;
                        }
                        found = true;
                    } else if (args[0] === moduleName) {
                        //Found matching define call for this script!
                        found = true;
                    }

                    callGetModule(args);
                }

                //Do this after the cycle of callGetModule in case the result
                //of those calls/init calls changes the registry.
                mod = getOwn(registry, moduleName);

                if (!found && !hasProp(defined, moduleName) && mod && !mod.inited) {
                    if (config.enforceDefine && (!shExports || !getGlobal(shExports))) {
                        if (hasPathFallback(moduleName)) {
                            return;
                        } else {
                            return onError(makeError('nodefine',
                                             'No define call for ' + moduleName,
                                             null,
                                             [moduleName]));
                        }
                    } else {
                        //A script that does not call define(), so just simulate
                        //the call for it.
                        callGetModule([moduleName, (shim.deps || []), shim.exportsFn]);
                    }
                }

                checkLoaded();
            },

            /**
             * Converts a module name to a file path. Supports cases where
             * moduleName may actually be just an URL.
             * Note that it **does not** call normalize on the moduleName,
             * it is assumed to have already been normalized. This is an
             * internal API, not a public one. Use toUrl for the public API.
             */
            nameToUrl: function (moduleName, ext) {
                var paths, pkgs, pkg, pkgPath, syms, i, parentModule, url,
                    parentPath;

                //If a colon is in the URL, it indicates a protocol is used and it is just
                //an URL to a file, or if it starts with a slash, contains a query arg (i.e. ?)
                //or ends with .js, then assume the user meant to use an url and not a module id.
                //The slash is important for protocol-less URLs as well as full paths.
                if (req.jsExtRegExp.test(moduleName)) {
                    //Just a plain path, not module name lookup, so just return it.
                    //Add extension if it is included. This is a bit wonky, only non-.js things pass
                    //an extension, this method probably needs to be reworked.
                    url = moduleName + (ext || '');
                } else {
                    //A module that needs to be converted to a path.
                    paths = config.paths;
                    pkgs = config.pkgs;

                    syms = moduleName.split('/');
                    //For each module name segment, see if there is a path
                    //registered for it. Start with most specific name
                    //and work up from it.
                    for (i = syms.length; i > 0; i -= 1) {
                        parentModule = syms.slice(0, i).join('/');
                        pkg = getOwn(pkgs, parentModule);
                        parentPath = getOwn(paths, parentModule);
                        if (parentPath) {
                            //If an array, it means there are a few choices,
                            //Choose the one that is desired
                            if (isArray(parentPath)) {
                                parentPath = parentPath[0];
                            }
                            syms.splice(0, i, parentPath);
                            break;
                        } else if (pkg) {
                            //If module name is just the package name, then looking
                            //for the main module.
                            if (moduleName === pkg.name) {
                                pkgPath = pkg.location + '/' + pkg.main;
                            } else {
                                pkgPath = pkg.location;
                            }
                            syms.splice(0, i, pkgPath);
                            break;
                        }
                    }

                    //Join the path parts together, then figure out if baseUrl is needed.
                    url = syms.join('/');
                    url += (ext || (/\?/.test(url) ? '' : '.js'));
                    url = (url.charAt(0) === '/' || url.match(/^[\w\+\.\-]+:/) ? '' : config.baseUrl) + url;
                }

                return config.urlArgs ? url +
                                        ((url.indexOf('?') === -1 ? '?' : '&') +
                                         config.urlArgs) : url;
            },

            //Delegates to req.load. Broken out as a separate function to
            //allow overriding in the optimizer.
            load: function (id, url) {
                req.load(context, id, url);
            },

            /**
             * Executes a module callack function. Broken out as a separate function
             * solely to allow the build system to sequence the files in the built
             * layer in the right sequence.
             *
             * @private
             */
            execCb: function (name, callback, args, exports) {
                return callback.apply(exports, args);
            },

            /**
             * callback for script loads, used to check status of loading.
             *
             * @param {Event} evt the event from the browser for the script
             * that was loaded.
             */
            onScriptLoad: function (evt) {
                //Using currentTarget instead of target for Firefox 2.0's sake. Not
                //all old browsers will be supported, but this one was easy enough
                //to support and still makes sense.
                if (evt.type === 'load' ||
                        (readyRegExp.test((evt.currentTarget || evt.srcElement).readyState))) {
                    //Reset interactive script so a script node is not held onto for
                    //to long.
                    interactiveScript = null;

                    //Pull out the name of the module and the context.
                    var data = getScriptData(evt);
                    context.completeLoad(data.id);
                }
            },

            /**
             * Callback for script errors.
             */
            onScriptError: function (evt) {
                var data = getScriptData(evt);
                if (!hasPathFallback(data.id)) {
                    return onError(makeError('scripterror', 'Script error', evt, [data.id]));
                }
            }
        };

        context.require = context.makeRequire();
        return context;
    }

    /**
     * Main entry point.
     *
     * If the only argument to require is a string, then the module that
     * is represented by that string is fetched for the appropriate context.
     *
     * If the first argument is an array, then it will be treated as an array
     * of dependency string names to fetch. An optional function callback can
     * be specified to execute when all of those dependencies are available.
     *
     * Make a local req variable to help Caja compliance (it assumes things
     * on a require that are not standardized), and to give a short
     * name for minification/local scope use.
     */
    req = requirejs = function (deps, callback, errback, optional) {

        //Find the right context, use default
        var context, config,
            contextName = defContextName;

        // Determine if have config object in the call.
        if (!isArray(deps) && typeof deps !== 'string') {
            // deps is a config object
            config = deps;
            if (isArray(callback)) {
                // Adjust args if there are dependencies
                deps = callback;
                callback = errback;
                errback = optional;
            } else {
                deps = [];
            }
        }

        if (config && config.context) {
            contextName = config.context;
        }

        context = getOwn(contexts, contextName);
        if (!context) {
            context = contexts[contextName] = req.s.newContext(contextName);
        }

        if (config) {
            context.configure(config);
        }

        return context.require(deps, callback, errback);
    };

    /**
     * Support require.config() to make it easier to cooperate with other
     * AMD loaders on globally agreed names.
     */
    req.config = function (config) {
        return req(config);
    };

    /**
     * Execute something after the current tick
     * of the event loop. Override for other envs
     * that have a better solution than setTimeout.
     * @param  {Function} fn function to execute later.
     */
    req.nextTick = typeof setTimeout !== 'undefined' ? function (fn) {
        setTimeout(fn, 4);
    } : function (fn) { fn(); };

    /**
     * Export require as a global, but only if it does not already exist.
     */
    if (!require) {
        require = req;
    }

    req.version = version;

    //Used to filter out dependencies that are already paths.
    req.jsExtRegExp = /^\/|:|\?|\.js$/;
    req.isBrowser = isBrowser;
    s = req.s = {
        contexts: contexts,
        newContext: newContext
    };

    //Create default context.
    req({});

    //Exports some context-sensitive methods on global require.
    each([
        'toUrl',
        'undef',
        'defined',
        'specified'
    ], function (prop) {
        //Reference from contexts instead of early binding to default context,
        //so that during builds, the latest instance of the default context
        //with its config gets used.
        req[prop] = function () {
            var ctx = contexts[defContextName];
            return ctx.require[prop].apply(ctx, arguments);
        };
    });

    if (isBrowser) {
        head = s.head = document.getElementsByTagName('head')[0];
        //If BASE tag is in play, using appendChild is a problem for IE6.
        //When that browser dies, this can be removed. Details in this jQuery bug:
        //http://dev.jquery.com/ticket/2709
        baseElement = document.getElementsByTagName('base')[0];
        if (baseElement) {
            head = s.head = baseElement.parentNode;
        }
    }

    /**
     * Any errors that require explicitly generates will be passed to this
     * function. Intercept/override it if you want custom error handling.
     * @param {Error} err the error object.
     */
    req.onError = function (err) {
        throw err;
    };

    /**
     * Does the request to load a module for the browser case.
     * Make this a separate function to allow other environments
     * to override it.
     *
     * @param {Object} context the require context to find state.
     * @param {String} moduleName the name of the module.
     * @param {Object} url the URL to the module.
     */
    req.load = function (context, moduleName, url) {
        var config = (context && context.config) || {},
            node;
        if (isBrowser) {
            //In the browser so use a script tag
            node = config.xhtml ?
                    document.createElementNS('http://www.w3.org/1999/xhtml', 'html:script') :
                    document.createElement('script');
            node.type = config.scriptType || 'text/javascript';
            node.charset = 'utf-8';
            node.async = true;

            node.setAttribute('data-requirecontext', context.contextName);
            node.setAttribute('data-requiremodule', moduleName);

            //Set up load listener. Test attachEvent first because IE9 has
            //a subtle issue in its addEventListener and script onload firings
            //that do not match the behavior of all other browsers with
            //addEventListener support, which fire the onload event for a
            //script right after the script execution. See:
            //https://connect.microsoft.com/IE/feedback/details/648057/script-onload-event-is-not-fired-immediately-after-script-execution
            //UNFORTUNATELY Opera implements attachEvent but does not follow the script
            //script execution mode.
            if (node.attachEvent &&
                    //Check if node.attachEvent is artificially added by custom script or
                    //natively supported by browser
                    //read https://github.com/jrburke/requirejs/issues/187
                    //if we can NOT find [native code] then it must NOT natively supported.
                    //in IE8, node.attachEvent does not have toString()
                    //Note the test for "[native code" with no closing brace, see:
                    //https://github.com/jrburke/requirejs/issues/273
                    !(node.attachEvent.toString && node.attachEvent.toString().indexOf('[native code') < 0) &&
                    !isOpera) {
                //Probably IE. IE (at least 6-8) do not fire
                //script onload right after executing the script, so
                //we cannot tie the anonymous define call to a name.
                //However, IE reports the script as being in 'interactive'
                //readyState at the time of the define call.
                useInteractive = true;

                node.attachEvent('onreadystatechange', context.onScriptLoad);
                //It would be great to add an error handler here to catch
                //404s in IE9+. However, onreadystatechange will fire before
                //the error handler, so that does not help. If addEvenListener
                //is used, then IE will fire error before load, but we cannot
                //use that pathway given the connect.microsoft.com issue
                //mentioned above about not doing the 'script execute,
                //then fire the script load event listener before execute
                //next script' that other browsers do.
                //Best hope: IE10 fixes the issues,
                //and then destroys all installs of IE 6-9.
                //node.attachEvent('onerror', context.onScriptError);
            } else {
                node.addEventListener('load', context.onScriptLoad, false);
                node.addEventListener('error', context.onScriptError, false);
            }
            node.src = url;

            //For some cache cases in IE 6-8, the script executes before the end
            //of the appendChild execution, so to tie an anonymous define
            //call to the module name (which is stored on the node), hold on
            //to a reference to this node, but clear after the DOM insertion.
            currentlyAddingScript = node;
            if (baseElement) {
                head.insertBefore(node, baseElement);
            } else {
                head.appendChild(node);
            }
            currentlyAddingScript = null;

            return node;
        } else if (isWebWorker) {
            //In a web worker, use importScripts. This is not a very
            //efficient use of importScripts, importScripts will block until
            //its script is downloaded and evaluated. However, if web workers
            //are in play, the expectation that a build has been done so that
            //only one script needs to be loaded anyway. This may need to be
            //reevaluated if other use cases become common.
            importScripts(url);

            //Account for anonymous modules
            context.completeLoad(moduleName);
        }
    };

    function getInteractiveScript() {
        if (interactiveScript && interactiveScript.readyState === 'interactive') {
            return interactiveScript;
        }

        eachReverse(scripts(), function (script) {
            if (script.readyState === 'interactive') {
                return (interactiveScript = script);
            }
        });
        return interactiveScript;
    }

    //Look for a data-main script attribute, which could also adjust the baseUrl.
    if (isBrowser) {
        //Figure out baseUrl. Get it from the script tag with require.js in it.
        eachReverse(scripts(), function (script) {
            //Set the 'head' where we can append children by
            //using the script's parent.
            if (!head) {
                head = script.parentNode;
            }

            //Look for a data-main attribute to set main script for the page
            //to load. If it is there, the path to data main becomes the
            //baseUrl, if it is not already set.
            dataMain = script.getAttribute('data-main');
            if (dataMain) {
                //Set final baseUrl if there is not already an explicit one.
                if (!cfg.baseUrl) {
                    //Pull off the directory of data-main for use as the
                    //baseUrl.
                    src = dataMain.split('/');
                    mainScript = src.pop();
                    subPath = src.length ? src.join('/')  + '/' : './';

                    cfg.baseUrl = subPath;
                    dataMain = mainScript;
                }

                //Strip off any trailing .js since dataMain is now
                //like a module name.
                dataMain = dataMain.replace(jsSuffixRegExp, '');

                //Put the data-main script in the files to load.
                cfg.deps = cfg.deps ? cfg.deps.concat(dataMain) : [dataMain];

                return true;
            }
        });
    }

    /**
     * The function that handles definitions of modules. Differs from
     * require() in that a string for the module should be the first argument,
     * and the function to execute after dependencies are loaded should
     * return a value to define the module corresponding to the first argument's
     * name.
     */
    define = function (name, deps, callback) {
        var node, context;

        //Allow for anonymous modules
        if (typeof name !== 'string') {
            //Adjust args appropriately
            callback = deps;
            deps = name;
            name = null;
        }

        //This module may not have dependencies
        if (!isArray(deps)) {
            callback = deps;
            deps = [];
        }

        //If no name, and callback is a function, then figure out if it a
        //CommonJS thing with dependencies.
        if (!deps.length && isFunction(callback)) {
            //Remove comments from the callback string,
            //look for require calls, and pull them into the dependencies,
            //but only if there are function args.
            if (callback.length) {
                callback
                    .toString()
                    .replace(commentRegExp, '')
                    .replace(cjsRequireRegExp, function (match, dep) {
                        deps.push(dep);
                    });

                //May be a CommonJS thing even without require calls, but still
                //could use exports, and module. Avoid doing exports and module
                //work though if it just needs require.
                //REQUIRES the function to expect the CommonJS variables in the
                //order listed below.
                deps = (callback.length === 1 ? ['require'] : ['require', 'exports', 'module']).concat(deps);
            }
        }

        //If in IE 6-8 and hit an anonymous define() call, do the interactive
        //work.
        if (useInteractive) {
            node = currentlyAddingScript || getInteractiveScript();
            if (node) {
                if (!name) {
                    name = node.getAttribute('data-requiremodule');
                }
                context = contexts[node.getAttribute('data-requirecontext')];
            }
        }

        //Always save off evaluating the def call until the script onload handler.
        //This allows multiple modules to be in a file without prematurely
        //tracing dependencies, and allows for anonymous module support,
        //where the module name is not known until the script onload event
        //occurs. If no context, use the global queue, and get it processed
        //in the onscript load callback.
        (context ? context.defQueue : globalDefQueue).push([name, deps, callback]);
    };

    define.amd = {
        jQuery: true
    };


    /**
     * Executes the text. Normally just uses eval, but can be modified
     * to use a better, environment-specific call. Only used for transpiling
     * loader plugins, not for plain JS modules.
     * @param {String} text the text to execute/evaluate.
     */
    req.exec = function (text) {
        /*jslint evil: true */
        return eval(text);
    };

    //Set up with config info.
    req(cfg);
}(this));

define("requireLib", function(){});

var jam = {
    "packages": [
        {
            "name": "cs-full",
            "location": "jam/cs-full"
        },
        {
            "name": "cs-offline",
            "location": "jam/cs-offline"
        }
    ],
    "version": "0.2.17",
    "shim": {}
};

if (typeof require !== "undefined" && require.config) {
    require.config({packages: jam.packages, shim: jam.shim});
}
else {
    var require = {packages: jam.packages, shim: jam.shim};
}

if (typeof exports !== "undefined" && typeof module !== "undefined") {
    module.exports = jam;
};
define("jam/require.config", function(){});

/**
	@module Base
	@memberOf CS
*/
define('src/csbase',[],function() {
	/*
	 * Date.toISOString polyfill from Mozilla for IE8
	 */
	if (!Date.prototype.toISOString) {
		(function() {
			function pad(number) {
				var r = String(number);
				if ( r.length === 1 ) {
					r = '0' + r;
				}
				return r;
			}

			Date.prototype.toISOString = function() {
				return this.getUTCFullYear()
					+ '-' + pad(this.getUTCMonth() + 1)
					+ '-' + pad(this.getUTCDate())
					+ 'T' + pad(this.getUTCHours())
					+ ':' + pad(this.getUTCMinutes())
					+ ':' + pad(this.getUTCSeconds())
					+ '.' + String( (this.getUTCMilliseconds()/1000).toFixed(3) ).slice( 2, 5 )
					+ 'Z';
			};
		}() );
	}

	/*
	 * Function.bind polyfill from Mozilla for IE8
	 */
	if (!Function.prototype.bind) {
		Function.prototype.bind = function (oThis) {
			if (typeof this !== "function") {
				// closest thing possible to the ECMAScript 5 internal IsCallable function
				throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
			}

			var aArgs = Array.prototype.slice.call(arguments, 1), 
				fToBind = this, 
				fNOP = function () {},
				fBound = function () {
					return fToBind.apply(this instanceof fNOP && oThis ? this : oThis, aArgs.concat(Array.prototype.slice.call(arguments)));
				};

			fNOP.prototype = this.prototype;
			fBound.prototype = new fNOP();

			return fBound;
		};
	}

	/*
	 * console[x].apply hack for IE8 from http://stackoverflow.com/questions/5538972/console-log-apply-not-working-in-ie9
	 */
	if (Function.prototype.bind && window.console && typeof console.log == "object"){
	    [
	      "log","info","warn","error","assert","dir","clear","profile","profileEnd"
	    ].forEach(function (method) {
	        console[method] = this.bind(console[method], console);
	    }, Function.prototype.call);
	}	

	return (function(){
		var logLevel = location.href.match(/[^\?]+\?(.+\&)?log=([^&]+).*/);
		logLevel = logLevel ? logLevel[2] : 'INFO';

		/**
		 *	@exports Log
		 *
		 *	Log to JavaScript console, respecting the log level which has been set.
		 *	Logging will be ignored for any level below the current one set (default is INFO).
		 *	Levels (in order): OFF, DEBUG, INFO, WARN, ERROR.
		 *		e.g. CS.Log.setLevel(CS.Log.DEBUG)
		 *
		 *		CS.Log.debug(arguments...)
		 *		CS.Log.info(arguments...)
		 *		CS.Log.error(arguments...)
		 *		CS.Log.warn(arguments...)
		 */
		var Log = function Log(initialLevel) {
			var level = initialLevel,
				slice = [].slice,
				console = window.console || {
					log: function () {},
					debug: function () {},
					info: function () {},
					warn: function () {},
					error: function () {}
				};

			function enabledForLevel(requested) {
				var actNum = logger[level];
				return (actNum && requested && requested >= actNum);
			}

			function logWithTimestamp(f, a, l) {
				var timestamp = '[' + new Date().toISOString().substring(11,23) + ']',
					args = slice.call(a);
				args.unshift(l);
				args.unshift(timestamp);
				if (f) f.apply(console, args);
				else console.log.apply(console, args);
			}

			this.logger = {
				'OFF': 0,
				'DEBUG': 1,
				'INFO': 2,
				'WARN': 3,
				'ERROR': 4,

				replace: function(newConsole) {
					if (!newConsole ||
							typeof(newConsole.debug) != 'function' ||
							typeof(newConsole.info) != 'function' ||
							typeof(newConsole.warn) != 'function' ||
							typeof(newConsole.error) != 'function'
					) {
						throw 'Supplied console object must implement debug, info, warn, error';
					}
					console = newConsole;
				},

				debug: function debug() {
					if (enabledForLevel(this.DEBUG)) {
						logWithTimestamp(console.debug, arguments, 'DEBUG');
					}
				},

				info: function info() {
					if (enabledForLevel(this.INFO)) {
						logWithTimestamp(console.info, arguments, 'INFO ');
					}
				},

				warn: function warn() {
					if (enabledForLevel(this.WARN)) {
						logWithTimestamp(console.warn, arguments, 'WARN ');
					}
				},

				error: function error() {
					if (enabledForLevel(this.ERROR)) {
						logWithTimestamp(console.error, arguments, 'ERROR');
					}
				},

				setLevel: function setLevel(l) {
					var levelNum = this[l];
					if (levelNum === 0 || levelNum) {
						level = l;
					} else {
						console.error('Level ' + l + ' not recognised');
					}
				},
				
				isDebugEnabled: function() { return enabledForLevel(this.DEBUG); },
				isInfoEnabled: function() { return enabledForLevel(this.INFO); },
				isWarnEnabled: function() { return enabledForLevel(this.WARN); },
				isErrorEnabled: function() { return enabledForLevel(this.ERROR); }
			};

			return logger;

		}(logLevel);

		// chuck CS into global scope for backwards compatibility
		var CS = window.CS ? window.CS : window.CS = {};
		CS.Log = Log;
		return CS;

		/*var preserved = window.CS;

		var CS = {
			Log: Log,
			
			module: function(name, module) {
				if (this[name]) {
					if (Log.isWarnEnabled()) Log.warn('Module with name ' + name + ' already exists, skipping...', module);
					return;
				}
				
				if (typeof(module) == 'function') {
					if (Log.isDebugEnabled()) Log.debug('Registered function module: ' + name);
					this[name] = module.bind(CS)();
				} else {
					this[name] = function() { return module; }.bind(CS)();
					if (Log.isDebugEnabled()) Log.debug('Registered object module: ' + name);
				}
			}/*,
			
			noConflict: function() {
				window.CS = preserved;
				return this;
			}
		};

		return CS;*/
	})();
});
/**
	@module Util
	@memberOf CS
	@requires Base
*/
define('src/csutil',[
	'./csbase'
], function(CS) {
	var Log = CS.Log,
		synchronisers = {},
		syncCount = 1,
		REFERENCE_REGEX = /(.+_)(\d+)/;

	/*\
	|*|
	|*|  Base64 / binary data / UTF-8 strings utilities
	|*|
	|*|  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Base64_encoding_and_decoding
	|*|
	\*/

	/* Array of bytes to base64 string decoding */

	function b64ToUint6 (nChr) {

	  return nChr > 64 && nChr < 91 ?
	      nChr - 65
	    : nChr > 96 && nChr < 123 ?
	      nChr - 71
	    : nChr > 47 && nChr < 58 ?
	      nChr + 4
	    : nChr === 43 ?
	      62
	    : nChr === 47 ?
	      63
	    :
	      0;

	}

	function base64DecToArr (sBase64, nBlocksSize) {

	  var
	    sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
	    nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 + 1 >> 2, taBytes = new Uint8Array(nOutLen);

	  for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
	    nMod4 = nInIdx & 3;
	    nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 18 - 6 * nMod4;
	    if (nMod4 === 3 || nInLen - nInIdx === 1) {
	      for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
	        taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
	      }
	      nUint24 = 0;

	    }
	  }

	  return taBytes;
	}

	/* Base64 string to array encoding */

	function uint6ToB64 (nUint6) {

	  return nUint6 < 26 ?
	      nUint6 + 65
	    : nUint6 < 52 ?
	      nUint6 + 71
	    : nUint6 < 62 ?
	      nUint6 - 4
	    : nUint6 === 62 ?
	      43
	    : nUint6 === 63 ?
	      47
	    :
	      65;

	}

	function base64EncArr (aBytes) {

	  var nMod3 = 2, sB64Enc = "";

	  for (var nLen = aBytes.length, nUint24 = 0, nIdx = 0; nIdx < nLen; nIdx++) {
	    nMod3 = nIdx % 3;
	    if (nIdx > 0 && (nIdx * 4 / 3) % 76 === 0) { sB64Enc += "\r\n"; }
	    nUint24 |= aBytes[nIdx] << (16 >>> nMod3 & 24);
	    if (nMod3 === 2 || aBytes.length - nIdx === 1) {
	      sB64Enc += String.fromCharCode(uint6ToB64(nUint24 >>> 18 & 63), uint6ToB64(nUint24 >>> 12 & 63), uint6ToB64(nUint24 >>> 6 & 63), uint6ToB64(nUint24 & 63));
	      nUint24 = 0;
	    }
	  }

	  return sB64Enc.substr(0, sB64Enc.length - 2 + nMod3) + (nMod3 === 2 ? '' : nMod3 === 1 ? '=' : '==');

	}

	/* UTF-8 array to DOMString and vice versa */

	function UTF8ArrToStr (aBytes) {

	  var sView = "";

	  for (var nPart, nLen = aBytes.length, nIdx = 0; nIdx < nLen; nIdx++) {
	    nPart = aBytes[nIdx];
	    sView += String.fromCharCode(
	      nPart > 251 && nPart < 254 && nIdx + 5 < nLen ? /* six bytes */
	        /* (nPart - 252 << 32) is not possible in ECMAScript! So...: */
	        (nPart - 252) * 1073741824 + (aBytes[++nIdx] - 128 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
	      : nPart > 247 && nPart < 252 && nIdx + 4 < nLen ? /* five bytes */
	        (nPart - 248 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
	      : nPart > 239 && nPart < 248 && nIdx + 3 < nLen ? /* four bytes */
	        (nPart - 240 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
	      : nPart > 223 && nPart < 240 && nIdx + 2 < nLen ? /* three bytes */
	        (nPart - 224 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
	      : nPart > 191 && nPart < 224 && nIdx + 1 < nLen ? /* two bytes */
	        (nPart - 192 << 6) + aBytes[++nIdx] - 128
	      : /* nPart < 127 ? */ /* one byte */
	        nPart
	    );
	  }

	  return sView;

	}

	function strToUTF8Arr (sDOMStr) {

	  var aBytes, nChr, nStrLen = sDOMStr.length, nArrLen = 0;

	  /* mapping... */

	  for (var nMapIdx = 0; nMapIdx < nStrLen; nMapIdx++) {
	    nChr = sDOMStr.charCodeAt(nMapIdx);
	    nArrLen += nChr < 0x80 ? 1 : nChr < 0x800 ? 2 : nChr < 0x10000 ? 3 : nChr < 0x200000 ? 4 : nChr < 0x4000000 ? 5 : 6;
	  }

	  aBytes = new Uint8Array(nArrLen);

	  /* transcription... */

	  for (var nIdx = 0, nChrIdx = 0; nIdx < nArrLen; nChrIdx++) {
	    nChr = sDOMStr.charCodeAt(nChrIdx);
	    if (nChr < 128) {
	      /* one byte */
	      aBytes[nIdx++] = nChr;
	    } else if (nChr < 0x800) {
	      /* two bytes */
	      aBytes[nIdx++] = 192 + (nChr >>> 6);
	      aBytes[nIdx++] = 128 + (nChr & 63);
	    } else if (nChr < 0x10000) {
	      /* three bytes */
	      aBytes[nIdx++] = 224 + (nChr >>> 12);
	      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
	      aBytes[nIdx++] = 128 + (nChr & 63);
	    } else if (nChr < 0x200000) {
	      /* four bytes */
	      aBytes[nIdx++] = 240 + (nChr >>> 18);
	      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
	      aBytes[nIdx++] = 128 + (nChr & 63);
	    } else if (nChr < 0x4000000) {
	      /* five bytes */
	      aBytes[nIdx++] = 248 + (nChr >>> 24);
	      aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
	      aBytes[nIdx++] = 128 + (nChr & 63);
	    } else /* if (nChr <= 0x7fffffff) */ {
	      /* six bytes */
	      aBytes[nIdx++] = 252 + /* (nChr >>> 32) is not possible in ECMAScript! So...: */ (nChr / 1073741824);
	      aBytes[nIdx++] = 128 + (nChr >>> 24 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
	      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
	      aBytes[nIdx++] = 128 + (nChr & 63);
	    }
	  }

	  return aBytes;

	}

	return {

		base64Decode: function base64Decode(data) {
			//return Base64.decode(data);
		},

		base64Encode: function base64Encode(data) {
			return base64EncArr(strToUTF8Arr(data));
			//return Base64.encode(data);
			/*var uInt8Array = new Uint8Array(data),
				i = uInt8Array.length,
				binaryString = new Array(i),
				raw;

			while (i--) {
				binaryString[i] = String.fromCharCode(uInt8Array[i]);
			}

			raw = binaryString.join('');

			return window.btoa(raw);*/
		},

		/*
		 * CallbackSynchroniser factory function
		 * Call with a continuation function, returns an initialised synchroniser with which
		 * multiple callbacks can be registered - on completion the continuation function is called
		 */
		callbackSynchroniser: function callbackSynchroniser(name, continuation, defaultTaskTimeout) {
			var tasks = {},
				started = false,
				progress,
				CANCELLED = 'Cancelled',
				COMPLETE = 'Complete',
				ERROR = 'Error',
				NOT_STARTED = 'Not Started',
				RETRY = 'Retry',
				STARTED = 'Started',
				TIMED_OUT = 'Timed Out',
				WAITING = 'Waiting';

			if (typeof name === 'object' || typeof name === 'function') {
				defaultTaskTimeout = continuation;
				continuation = name;
				name = 'Synchroniser';
			}

			name = syncCount + ' ' + name;

			if (typeof continuation === 'function') {
				continuation = {success: continuation};
			}

			function attemptRetry(task) {
				if (!task.retries) {
					return false;
				}
				task.retries--;
				task.status = RETRY;
				return true;
			}

			function cancelTasks() {
				jQuery.each(tasks, function(k, v){
					if (v.status === WAITING || v.status === NOT_STARTED) {
						v.status = CANCELLED;
						v.f = function() {
							CS.Log.info('Task cancelled: ' + v.name);
						};
					}
				});
			}

			function checkTasks() {
				setTimeout(function() {
					//CS.Log.info('Check Tasks: ' + name);
					var complete = true,
						error = false;
					jQuery.each(tasks, function(k, v) {
						if (v.status === WAITING) {
							complete = false;
						} else if (v.status === NOT_STARTED || v.status === RETRY) {
							complete = false;
							if (v.status === RETRY) {
								Log.info('Retrying ' + v.name + ' (' + v.retries + ' remaining)');
							}
							try {
								executeTask(v);
							} catch (e) {
								v.status = ERROR;
							}
						} else if (v.status === ERROR || v.status === TIMED_OUT) {
							error = true;
						}
					});
					if (complete && started) {
						started = false; // prevent potential double firing by multiple timers
						if (progress && jQuery.mobile) { // TODO - pluggable progress indicator
							jQuery.mobile.loading('hide');
						}
						if (error) {
							CS.Log.warn('Synchronised task failed: ' + name);
							if (continuation.error) {
								continuation.error();
								return;
							}
						}
						continuation.success();
					}
				}, 50);
			}

			function executeTask(t) {
				if (Log.isInfoEnabled() && !t.suppressLogging) {
					Log.info('Executing task: ', t.name);
				}
				t.startTime = new Date().getTime();
				if (t.timeout) {
					t.timer = window.setTimeout(getTimeout(t), t.timeout);
				}
				t.status = 'Waiting';
				t.f();
			}

			function getTimeout(t) {
				return function() {
					if (t.status === WAITING) {
						t.status = TIMED_OUT;
						t.endTime = new Date().getTime();
						attemptRetry(t);
						checkTasks();
					}
				};
			}

			var sync = {
				complete: function(name) {
					var task = tasks[name];
					if (task) {
						Log.debug('Synchroniser task ' + name + ' completed');
						task.status = COMPLETE;
						task.endTime = new Date().getTime();
						checkTasks();
					} else {
						Log.warn('Synchroniser task ' + name + ' not recognised');
					}
				},

				error: function(name, info) {
					var task = tasks[name];
					if (task) {
						Log.info('Synchroniser task ' + name + ' errored', info);
						task.status = ERROR;
						task.endTime = new Date().getTime();
						task.message = info;
						if (!attemptRetry(task)) {
							cancelTasks();
						}
						/*if (continuation.error) {
							continuation.error(info);
						}*/
						checkTasks();
					} else {
						Log.warn('Synchroniser task ' + name + ' not recognised');
					}
				},

				register: function(task, f, timeout, retries) {
					if (typeof task === 'string') {
						task = {name: task, f: f, timeout: timeout, retries: retries};
					}
					task.timeout = task.timeout || defaultTaskTimeout;
					task.status = NOT_STARTED;
					tasks[task.name] = task;
					Log.debug('Synchroniser registered task: ' + name);
				},

				start: function(p) {
					if (started) {
						Log.error('Synchroniser already started');
						return;
					}
					started = true;
					progress = p;
					if (progress && jQuery.mobile) {
						if (progress.text) {
							progress.textVisible = true;
						}
						progress.theme = 'a';
						jQuery.mobile.loading('show', progress);
					}
					jQuery.each(tasks, function(k, v){
						executeTask(v);
					});
					checkTasks();
				},

				status: function(highLevel) {
					var s = '',
						hl = '',
						complete = true,
						error = false,
						time;
					jQuery.each(tasks, function(k, v) {
						if (v.startTime) {
							time = (v.endTime ? (v.endTime - v.startTime) : (new Date().getTime() - v.startTime)) / 1000;
						} else {
							time = 0;
						}
						s += k + ': ' + v.status + ' [' + time + ' secs] \n';
						if (v.status === WAITING) {
							complete = false;
						} else if (v.status === ERROR || v.status === TIMED_OUT) {
							error = true;
							s += '\t' + v.message + '\n';
						}
					});
					hl = 'Synchroniser: ' + (complete ? COMPLETE : error ? ERROR : started ? STARTED : NOT_STARTED);
					if (error) {
						hl += ' with errors';
					}
					s = hl + '\n' + s;
					return highLevel ? hl : s;
				}

			};

			synchronisers[name] = sync;
			syncCount++;

			return sync;
		},

		getCallbackSynchronisers: function callbackSynchronisers() {
			var syncs = {},
				i = 1;
			for (var name in synchronisers) {
				var sync = synchronisers[name],
					s = {
						status: sync.status(),
						sync: sync
					};
				syncs[i++] = s;
			}
			return syncs;
		},

		getCallbackSynchroniserStatuses: function callbackSynchronisers() {
			var syncs = {};
			for (var name in synchronisers) {
				var sync = synchronisers[name],
					s = {
						status: sync.status(),
						sync: sync
					};
				syncs[name] = sync.status(true);
			}
			return syncs;
		},

		configuratorPrefix: 'cscfga__',

		cssEscape: function cssEscape(v) {
			return v ? v.replace(/([:\/#;&,\.\+\*~'"!\?\^\$\[\]\(\)=>\|])/g, '\\$1') : v;
		},

		endsWith: function endsWith(str, tail) {
			var tailLen = tail.length;
			var strLen = str.length;
			return strLen >= tailLen && str.substr(strLen-tailLen, tailLen) === tail;
		},

		generateGUID: function generateGUID() {
			return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {var r = Math.random()*16|0,v=c=='x'?r:r&0x3|0x8;return v.toString(16);});
		},

		generateId: function generateId(name) {
			return name.replace(/[\s\|:]/g, '_').replace(/['"]/g, '');
		},

		generateReference: function generateReference(name, context) {
			context = context || {};
			var prefix = context.ref ? context.ref + ':' : '',
				suffix = '_' + (context.index ? context.index : '0'),
				id = this.generateId(name);
			return prefix + id + suffix;
		},

		getAnchorReference: function getAnchorReference(ref) {
			return ref === '' ? ref : this.stripReference(ref) + '0';
		},

		getParentReference: function getParentReference(ref) {
			var idx = ref ? ref.lastIndexOf(':') : -1,
				parentRef = idx > 0 ? ref.substring(0, idx) : '';

			return parentRef;
		},

		getQueryParams: function getQueryParams() {
			if (!this.queryParams) {
				var match,
					pl = /\+/g,
					search = /([^&=]+)=?([^&]*)/g,
					decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
					query = window.location.search.substring(1);

				this.queryParams = {};

				while (match = search.exec(query)) {
					this.queryParams[decode(match[1])] = decode(match[2]);
				}
			}
			return this.queryParams;
		},

		getReferenceIndex: function getReferenceIndex(ref) {
			return ref ? parseInt(ref.match(REFERENCE_REGEX)[2], 10) : 0;
		},

		hashCode: function hashCode(str) {
			return str.split("").reduce(function(a, b) {
					a = ((a << 5) - a) + b.charCodeAt(0);
					return a & a;
				}, 0);
		},

		isEmpty: function isEmpty(o) {
			for(var p in o) {
				if (o.hasOwnProperty(p)) {
					return false;
				}
			}
			return true;
		},

		offlinePrefix: 'cfgoffline__',

		onPageCreate: function onPageCreate(f) {
			if (jQuery && jQuery.mobile) {
				jQuery("div:jqmData(role='page'):last").bind('pagecreate', f);
			} else {
				jQuery(document).ready(f);
			}
		},

		onPageInit: function onPageInit(f) {
			if (jQuery && jQuery.mobile) {
				jQuery("div:jqmData(role='page'):last").bind('pageinit', f);
			} else {
				jQuery(document).ready(f);
			}
		},

		onPageShow: function onPageShow(f) {
			if (jQuery && jQuery.mobile) {
				jQuery("div:jqmData(role='page'):last").bind('pageshow', f);
			} else {
				jQuery(document).ready(f);
			}
		},

		startsWith: function startsWith(str, head) {
			var headLen = head.length;
			return str.length >= headLen && str.substr(0, headLen) === head;
		},

		stripReference: function stripReference(ref) {
			return ref.match(REFERENCE_REGEX)[1];
		},

		template: (function(){
			var cache = {};

			var template = function template(str, data){
				if (data) {
					data.parameterize = parameterize;
				}
				var fn = !/[\W:]+/.test(str) ?
					cache[str] = cache[str] || template(document.getElementById(str).innerHTML) :
					new Function(
						"obj",
						"var p=[],print=function(){p.push.apply(p,arguments);};" +
							"with(obj){p.push('" +
							str.replace(/[\r\t\n]/g, " ")
								.replace(/'(?=[^%]*%>)/g,"\t")
								.split("'").join("\\'")
								.split("\t").join("'")
								.replace(/<%=(.+?)%>/g, "',$1,'")
								.split("<%").join("');")
								.split("%>").join("p.push('") +
								"');}return p.join('');"
				);
				return data ? fn(data) : fn;
			};
			return template;

			function parameterize(params) {
				return JSON.stringify(params).replace(/\"/g, '&quot;'.replace(/\n/g, ' '));
			}
		})(),

		validateProperties: function validateProperties(o, name, toValidate) {
			var generic = 'property',
				types = {},
				i,
				t;

			if (jQuery.isArray(toValidate)) {
				types.property = toValidate;
			} else {
				for (t in toValidate) {
					types[t] = toValidate[t];
				}
			}

			for (t in types) {
				var props = types[t];
				i = props.length;
				while (i--) {
					var prop = o[props[i]];
					if (prop === undefined) {
						return 'Malformed ' + name + ': required ' + t + ' ' + props[i] + ' missing';
					} else if (t !== generic && typeof(prop) !== t) {
						return 'Malformed ' + name + ': required ' + t + ' ' + prop + ' is wrong type (' + typeof(prop) + ')';
					}
				}
			}
		}

	};
});
// vim:ts=4:sts=4:sw=4:
/*!
 *
 * Copyright 2009-2012 Kris Kowal under the terms of the MIT
 * license found at http://github.com/kriskowal/q/raw/master/LICENSE
 *
 * With parts by Tyler Close
 * Copyright 2007-2009 Tyler Close under the terms of the MIT X license found
 * at http://www.opensource.org/licenses/mit-license.html
 * Forked at ref_send.js version: 2009-05-11
 *
 * With parts by Mark Miller
 * Copyright (C) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

(function (definition) {
    // Turn off strict mode for this function so we can assign to global.Q
    /* jshint strict: false */

    // This file will function properly as a <script> tag, or a module
    // using CommonJS and NodeJS or RequireJS module formats.  In
    // Common/Node/RequireJS, the module exports the Q API and when
    // executed as a simple <script>, it creates a Q global instead.

    // Montage Require
    if (typeof bootstrap === "function") {
        bootstrap("promise", definition);

    // CommonJS
    } else if (typeof exports === "object") {
        module.exports = definition();

    // RequireJS
    } else if (typeof define === "function" && define.amd) {
        define('node_modules/q/q',definition);

    // SES (Secure EcmaScript)
    } else if (typeof ses !== "undefined") {
        if (!ses.ok()) {
            return;
        } else {
            ses.makeQ = definition;
        }

    // <script>
    } else {
        Q = definition();
    }

})(function () {


var hasStacks = false;
try {
    throw new Error();
} catch (e) {
    hasStacks = !!e.stack;
}

// All code after this point will be filtered from stack traces reported
// by Q.
var qStartingLine = captureLine();
var qFileName;

// shims

// used for fallback in "allResolved"
var noop = function () {};

// Use the fastest possible means to execute a task in a future turn
// of the event loop.
var nextTick =(function () {
    // linked list of tasks (single, with head node)
    var head = {task: void 0, next: null};
    var tail = head;
    var flushing = false;
    var requestTick = void 0;
    var isNodeJS = false;

    function flush() {
        /* jshint loopfunc: true */

        while (head.next) {
            head = head.next;
            var task = head.task;
            head.task = void 0;
            var domain = head.domain;

            if (domain) {
                head.domain = void 0;
                domain.enter();
            }

            try {
                task();

            } catch (e) {
                if (isNodeJS) {
                    // In node, uncaught exceptions are considered fatal errors.
                    // Re-throw them synchronously to interrupt flushing!

                    // Ensure continuation if the uncaught exception is suppressed
                    // listening "uncaughtException" events (as domains does).
                    // Continue in next event to avoid tick recursion.
                    if (domain) {
                        domain.exit();
                    }
                    setTimeout(flush, 0);
                    if (domain) {
                        domain.enter();
                    }

                    throw e;

                } else {
                    // In browsers, uncaught exceptions are not fatal.
                    // Re-throw them asynchronously to avoid slow-downs.
                    setTimeout(function() {
                       throw e;
                    }, 0);
                }
            }

            if (domain) {
                domain.exit();
            }
        }

        flushing = false;
    }

    nextTick = function (task) {
        tail = tail.next = {
            task: task,
            domain: isNodeJS && process.domain,
            next: null
        };

        if (!flushing) {
            flushing = true;
            requestTick();
        }
    };

    if (typeof process !== "undefined" && process.nextTick) {
        // Node.js before 0.9. Note that some fake-Node environments, like the
        // Mocha test runner, introduce a `process` global without a `nextTick`.
        isNodeJS = true;

        requestTick = function () {
            process.nextTick(flush);
        };

    } else if (typeof setImmediate === "function") {
        // In IE10, Node.js 0.9+, or https://github.com/NobleJS/setImmediate
        if (typeof window !== "undefined") {
            requestTick = setImmediate.bind(window, flush);
        } else {
            requestTick = function () {
                setImmediate(flush);
            };
        }

    } else if (typeof MessageChannel !== "undefined") {
        // modern browsers
        // http://www.nonblocking.io/2011/06/windownexttick.html
        var channel = new MessageChannel();
        // At least Safari Version 6.0.5 (8536.30.1) intermittently cannot create
        // working message ports the first time a page loads.
        channel.port1.onmessage = function () {
            requestTick = requestPortTick;
            channel.port1.onmessage = flush;
            flush();
        };
        var requestPortTick = function () {
            // Opera requires us to provide a message payload, regardless of
            // whether we use it.
            channel.port2.postMessage(0);
        };
        requestTick = function () {
            setTimeout(flush, 0);
            requestPortTick();
        };

    } else {
        // old browsers
        requestTick = function () {
            setTimeout(flush, 0);
        };
    }

    return nextTick;
})();

// Attempt to make generics safe in the face of downstream
// modifications.
// There is no situation where this is necessary.
// If you need a security guarantee, these primordials need to be
// deeply frozen anyway, and if you don’t need a security guarantee,
// this is just plain paranoid.
// However, this **might** have the nice side-effect of reducing the size of
// the minified code by reducing x.call() to merely x()
// See Mark Miller’s explanation of what this does.
// http://wiki.ecmascript.org/doku.php?id=conventions:safe_meta_programming
var call = Function.call;
function uncurryThis(f) {
    return function () {
        return call.apply(f, arguments);
    };
}
// This is equivalent, but slower:
// uncurryThis = Function_bind.bind(Function_bind.call);
// http://jsperf.com/uncurrythis

var array_slice = uncurryThis(Array.prototype.slice);

var array_reduce = uncurryThis(
    Array.prototype.reduce || function (callback, basis) {
        var index = 0,
            length = this.length;
        // concerning the initial value, if one is not provided
        if (arguments.length === 1) {
            // seek to the first value in the array, accounting
            // for the possibility that is is a sparse array
            do {
                if (index in this) {
                    basis = this[index++];
                    break;
                }
                if (++index >= length) {
                    throw new TypeError();
                }
            } while (1);
        }
        // reduce
        for (; index < length; index++) {
            // account for the possibility that the array is sparse
            if (index in this) {
                basis = callback(basis, this[index], index);
            }
        }
        return basis;
    }
);

var array_indexOf = uncurryThis(
    Array.prototype.indexOf || function (value) {
        // not a very good shim, but good enough for our one use of it
        for (var i = 0; i < this.length; i++) {
            if (this[i] === value) {
                return i;
            }
        }
        return -1;
    }
);

var array_map = uncurryThis(
    Array.prototype.map || function (callback, thisp) {
        var self = this;
        var collect = [];
        array_reduce(self, function (undefined, value, index) {
            collect.push(callback.call(thisp, value, index, self));
        }, void 0);
        return collect;
    }
);

var object_create = Object.create || function (prototype) {
    function Type() { }
    Type.prototype = prototype;
    return new Type();
};

var object_hasOwnProperty = uncurryThis(Object.prototype.hasOwnProperty);

var object_keys = Object.keys || function (object) {
    var keys = [];
    for (var key in object) {
        if (object_hasOwnProperty(object, key)) {
            keys.push(key);
        }
    }
    return keys;
};

var object_toString = uncurryThis(Object.prototype.toString);

function isObject(value) {
    return value === Object(value);
}

// generator related shims

// FIXME: Remove this function once ES6 generators are in SpiderMonkey.
function isStopIteration(exception) {
    return (
        object_toString(exception) === "[object StopIteration]" ||
        exception instanceof QReturnValue
    );
}

// FIXME: Remove this helper and Q.return once ES6 generators are in
// SpiderMonkey.
var QReturnValue;
if (typeof ReturnValue !== "undefined") {
    QReturnValue = ReturnValue;
} else {
    QReturnValue = function (value) {
        this.value = value;
    };
}

// Until V8 3.19 / Chromium 29 is released, SpiderMonkey is the only
// engine that has a deployed base of browsers that support generators.
// However, SM's generators use the Python-inspired semantics of
// outdated ES6 drafts.  We would like to support ES6, but we'd also
// like to make it possible to use generators in deployed browsers, so
// we also support Python-style generators.  At some point we can remove
// this block.
var hasES6Generators;
try {
    /* jshint evil: true, nonew: false */
    new Function("(function* (){ yield 1; })");
    hasES6Generators = true;
} catch (e) {
    hasES6Generators = false;
}

// long stack traces

var STACK_JUMP_SEPARATOR = "From previous event:";

function makeStackTraceLong(error, promise) {
    // If possible, transform the error stack trace by removing Node and Q
    // cruft, then concatenating with the stack trace of `promise`. See #57.
    if (hasStacks &&
        promise.stack &&
        typeof error === "object" &&
        error !== null &&
        error.stack &&
        error.stack.indexOf(STACK_JUMP_SEPARATOR) === -1
    ) {
        var stacks = [];
        for (var p = promise; !!p; p = p.source) {
            if (p.stack) {
                stacks.unshift(p.stack);
            }
        }
        stacks.unshift(error.stack);

        var concatedStacks = stacks.join("\n" + STACK_JUMP_SEPARATOR + "\n");
        error.stack = filterStackString(concatedStacks);
    }
}

function filterStackString(stackString) {
    var lines = stackString.split("\n");
    var desiredLines = [];
    for (var i = 0; i < lines.length; ++i) {
        var line = lines[i];

        if (!isInternalFrame(line) && !isNodeFrame(line) && line) {
            desiredLines.push(line);
        }
    }
    return desiredLines.join("\n");
}

function isNodeFrame(stackLine) {
    return stackLine.indexOf("(module.js:") !== -1 ||
           stackLine.indexOf("(node.js:") !== -1;
}

function getFileNameAndLineNumber(stackLine) {
    // Named functions: "at functionName (filename:lineNumber:columnNumber)"
    // In IE10 function name can have spaces ("Anonymous function") O_o
    var attempt1 = /at .+ \((.+):(\d+):(?:\d+)\)$/.exec(stackLine);
    if (attempt1) {
        return [attempt1[1], Number(attempt1[2])];
    }

    // Anonymous functions: "at filename:lineNumber:columnNumber"
    var attempt2 = /at ([^ ]+):(\d+):(?:\d+)$/.exec(stackLine);
    if (attempt2) {
        return [attempt2[1], Number(attempt2[2])];
    }

    // Firefox style: "function@filename:lineNumber or @filename:lineNumber"
    var attempt3 = /.*@(.+):(\d+)$/.exec(stackLine);
    if (attempt3) {
        return [attempt3[1], Number(attempt3[2])];
    }
}

function isInternalFrame(stackLine) {
    var fileNameAndLineNumber = getFileNameAndLineNumber(stackLine);

    if (!fileNameAndLineNumber) {
        return false;
    }

    var fileName = fileNameAndLineNumber[0];
    var lineNumber = fileNameAndLineNumber[1];

    return fileName === qFileName &&
        lineNumber >= qStartingLine &&
        lineNumber <= qEndingLine;
}

// discover own file name and line number range for filtering stack
// traces
function captureLine() {
    if (!hasStacks) {
        return;
    }

    try {
        throw new Error();
    } catch (e) {
        var lines = e.stack.split("\n");
        var firstLine = lines[0].indexOf("@") > 0 ? lines[1] : lines[2];
        var fileNameAndLineNumber = getFileNameAndLineNumber(firstLine);
        if (!fileNameAndLineNumber) {
            return;
        }

        qFileName = fileNameAndLineNumber[0];
        return fileNameAndLineNumber[1];
    }
}

function deprecate(callback, name, alternative) {
    return function () {
        if (typeof console !== "undefined" &&
            typeof console.warn === "function") {
            console.warn(name + " is deprecated, use " + alternative +
                         " instead.", new Error("").stack);
        }
        return callback.apply(callback, arguments);
    };
}

// end of shims
// beginning of real work

/**
 * Constructs a promise for an immediate reference, passes promises through, or
 * coerces promises from different systems.
 * @param value immediate reference or promise
 */
function Q(value) {
    // If the object is already a Promise, return it directly.  This enables
    // the resolve function to both be used to created references from objects,
    // but to tolerably coerce non-promises to promises.
    if (isPromise(value)) {
        return value;
    }

    // assimilate thenables
    if (isPromiseAlike(value)) {
        return coerce(value);
    } else {
        return fulfill(value);
    }
}
Q.resolve = Q;

/**
 * Performs a task in a future turn of the event loop.
 * @param {Function} task
 */
Q.nextTick = nextTick;

/**
 * Controls whether or not long stack traces will be on
 */
Q.longStackSupport = false;

/**
 * Constructs a {promise, resolve, reject} object.
 *
 * `resolve` is a callback to invoke with a more resolved value for the
 * promise. To fulfill the promise, invoke `resolve` with any value that is
 * not a thenable. To reject the promise, invoke `resolve` with a rejected
 * thenable, or invoke `reject` with the reason directly. To resolve the
 * promise to another thenable, thus putting it in the same state, invoke
 * `resolve` with that other thenable.
 */
Q.defer = defer;
function defer() {
    // if "messages" is an "Array", that indicates that the promise has not yet
    // been resolved.  If it is "undefined", it has been resolved.  Each
    // element of the messages array is itself an array of complete arguments to
    // forward to the resolved promise.  We coerce the resolution value to a
    // promise using the `resolve` function because it handles both fully
    // non-thenable values and other thenables gracefully.
    var messages = [], progressListeners = [], resolvedPromise;

    var deferred = object_create(defer.prototype);
    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, operands) {
        var args = array_slice(arguments);
        if (messages) {
            messages.push(args);
            if (op === "when" && operands[1]) { // progress operand
                progressListeners.push(operands[1]);
            }
        } else {
            nextTick(function () {
                resolvedPromise.promiseDispatch.apply(resolvedPromise, args);
            });
        }
    };

    // XXX deprecated
    promise.valueOf = function () {
        if (messages) {
            return promise;
        }
        var nearerValue = nearer(resolvedPromise);
        if (isPromise(nearerValue)) {
            resolvedPromise = nearerValue; // shorten chain
        }
        return nearerValue;
    };

    promise.inspect = function () {
        if (!resolvedPromise) {
            return { state: "pending" };
        }
        return resolvedPromise.inspect();
    };

    if (Q.longStackSupport && hasStacks) {
        try {
            throw new Error();
        } catch (e) {
            // NOTE: don't try to use `Error.captureStackTrace` or transfer the
            // accessor around; that causes memory leaks as per GH-111. Just
            // reify the stack trace as a string ASAP.
            //
            // At the same time, cut off the first line; it's always just
            // "[object Promise]\n", as per the `toString`.
            promise.stack = e.stack.substring(e.stack.indexOf("\n") + 1);
        }
    }

    // NOTE: we do the checks for `resolvedPromise` in each method, instead of
    // consolidating them into `become`, since otherwise we'd create new
    // promises with the lines `become(whatever(value))`. See e.g. GH-252.

    function become(newPromise) {
        resolvedPromise = newPromise;
        promise.source = newPromise;

        array_reduce(messages, function (undefined, message) {
            nextTick(function () {
                newPromise.promiseDispatch.apply(newPromise, message);
            });
        }, void 0);

        messages = void 0;
        progressListeners = void 0;
    }

    deferred.promise = promise;
    deferred.resolve = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(Q(value));
    };

    deferred.fulfill = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(fulfill(value));
    };
    deferred.reject = function (reason) {
        if (resolvedPromise) {
            return;
        }

        become(reject(reason));
    };
    deferred.notify = function (progress) {
        if (resolvedPromise) {
            return;
        }

        array_reduce(progressListeners, function (undefined, progressListener) {
            nextTick(function () {
                progressListener(progress);
            });
        }, void 0);
    };

    return deferred;
}

/**
 * Creates a Node-style callback that will resolve or reject the deferred
 * promise.
 * @returns a nodeback
 */
defer.prototype.makeNodeResolver = function () {
    var self = this;
    return function (error, value) {
        if (error) {
            self.reject(error);
        } else if (arguments.length > 2) {
            self.resolve(array_slice(arguments, 1));
        } else {
            self.resolve(value);
        }
    };
};

/**
 * @param resolver {Function} a function that returns nothing and accepts
 * the resolve, reject, and notify functions for a deferred.
 * @returns a promise that may be resolved with the given resolve and reject
 * functions, or rejected by a thrown exception in resolver
 */
Q.promise = promise;
function promise(resolver) {
    if (typeof resolver !== "function") {
        throw new TypeError("resolver must be a function.");
    }
    var deferred = defer();
    try {
        resolver(deferred.resolve, deferred.reject, deferred.notify);
    } catch (reason) {
        deferred.reject(reason);
    }
    return deferred.promise;
}

// XXX experimental.  This method is a way to denote that a local value is
// serializable and should be immediately dispatched to a remote upon request,
// instead of passing a reference.
Q.passByCopy = function (object) {
    //freeze(object);
    //passByCopies.set(object, true);
    return object;
};

Promise.prototype.passByCopy = function () {
    //freeze(object);
    //passByCopies.set(object, true);
    return this;
};

/**
 * If two promises eventually fulfill to the same value, promises that value,
 * but otherwise rejects.
 * @param x {Any*}
 * @param y {Any*}
 * @returns {Any*} a promise for x and y if they are the same, but a rejection
 * otherwise.
 *
 */
Q.join = function (x, y) {
    return Q(x).join(y);
};

Promise.prototype.join = function (that) {
    return Q([this, that]).spread(function (x, y) {
        if (x === y) {
            // TODO: "===" should be Object.is or equiv
            return x;
        } else {
            throw new Error("Can't join: not the same: " + x + " " + y);
        }
    });
};

/**
 * Returns a promise for the first of an array of promises to become fulfilled.
 * @param answers {Array[Any*]} promises to race
 * @returns {Any*} the first promise to be fulfilled
 */
Q.race = race;
function race(answerPs) {
    return promise(function(resolve, reject) {
        // Switch to this once we can assume at least ES5
        // answerPs.forEach(function(answerP) {
        //     Q(answerP).then(resolve, reject);
        // });
        // Use this in the meantime
        for (var i = 0, len = answerPs.length; i < len; i++) {
            Q(answerPs[i]).then(resolve, reject);
        }
    });
}

Promise.prototype.race = function () {
    return this.then(Q.race);
};

/**
 * Constructs a Promise with a promise descriptor object and optional fallback
 * function.  The descriptor contains methods like when(rejected), get(name),
 * set(name, value), post(name, args), and delete(name), which all
 * return either a value, a promise for a value, or a rejection.  The fallback
 * accepts the operation name, a resolver, and any further arguments that would
 * have been forwarded to the appropriate method above had a method been
 * provided with the proper name.  The API makes no guarantees about the nature
 * of the returned object, apart from that it is usable whereever promises are
 * bought and sold.
 */
Q.makePromise = Promise;
function Promise(descriptor, fallback, inspect) {
    if (fallback === void 0) {
        fallback = function (op) {
            return reject(new Error(
                "Promise does not support operation: " + op
            ));
        };
    }
    if (inspect === void 0) {
        inspect = function () {
            return {state: "unknown"};
        };
    }

    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, args) {
        var result;
        try {
            if (descriptor[op]) {
                result = descriptor[op].apply(promise, args);
            } else {
                result = fallback.call(promise, op, args);
            }
        } catch (exception) {
            result = reject(exception);
        }
        if (resolve) {
            resolve(result);
        }
    };

    promise.inspect = inspect;

    // XXX deprecated `valueOf` and `exception` support
    if (inspect) {
        var inspected = inspect();
        if (inspected.state === "rejected") {
            promise.exception = inspected.reason;
        }

        promise.valueOf = function () {
            var inspected = inspect();
            if (inspected.state === "pending" ||
                inspected.state === "rejected") {
                return promise;
            }
            return inspected.value;
        };
    }

    return promise;
}

Promise.prototype.toString = function () {
    return "[object Promise]";
};

Promise.prototype.then = function (fulfilled, rejected, progressed) {
    var self = this;
    var deferred = defer();
    var done = false;   // ensure the untrusted promise makes at most a
                        // single call to one of the callbacks

    function _fulfilled(value) {
        try {
            return typeof fulfilled === "function" ? fulfilled(value) : value;
        } catch (exception) {
            return reject(exception);
        }
    }

    function _rejected(exception) {
        if (typeof rejected === "function") {
            makeStackTraceLong(exception, self);
            try {
                return rejected(exception);
            } catch (newException) {
                return reject(newException);
            }
        }
        return reject(exception);
    }

    function _progressed(value) {
        return typeof progressed === "function" ? progressed(value) : value;
    }

    nextTick(function () {
        self.promiseDispatch(function (value) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_fulfilled(value));
        }, "when", [function (exception) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_rejected(exception));
        }]);
    });

    // Progress propagator need to be attached in the current tick.
    self.promiseDispatch(void 0, "when", [void 0, function (value) {
        var newValue;
        var threw = false;
        try {
            newValue = _progressed(value);
        } catch (e) {
            threw = true;
            if (Q.onerror) {
                Q.onerror(e);
            } else {
                throw e;
            }
        }

        if (!threw) {
            deferred.notify(newValue);
        }
    }]);

    return deferred.promise;
};

/**
 * Registers an observer on a promise.
 *
 * Guarantees:
 *
 * 1. that fulfilled and rejected will be called only once.
 * 2. that either the fulfilled callback or the rejected callback will be
 *    called, but not both.
 * 3. that fulfilled and rejected will not be called in this turn.
 *
 * @param value      promise or immediate reference to observe
 * @param fulfilled  function to be called with the fulfilled value
 * @param rejected   function to be called with the rejection exception
 * @param progressed function to be called on any progress notifications
 * @return promise for the return value from the invoked callback
 */
Q.when = when;
function when(value, fulfilled, rejected, progressed) {
    return Q(value).then(fulfilled, rejected, progressed);
}

Promise.prototype.thenResolve = function (value) {
    return this.then(function () { return value; });
};

Q.thenResolve = function (promise, value) {
    return Q(promise).thenResolve(value);
};

Promise.prototype.thenReject = function (reason) {
    return this.then(function () { throw reason; });
};

Q.thenReject = function (promise, reason) {
    return Q(promise).thenReject(reason);
};

/**
 * If an object is not a promise, it is as "near" as possible.
 * If a promise is rejected, it is as "near" as possible too.
 * If it’s a fulfilled promise, the fulfillment value is nearer.
 * If it’s a deferred promise and the deferred has been resolved, the
 * resolution is "nearer".
 * @param object
 * @returns most resolved (nearest) form of the object
 */

// XXX should we re-do this?
Q.nearer = nearer;
function nearer(value) {
    if (isPromise(value)) {
        var inspected = value.inspect();
        if (inspected.state === "fulfilled") {
            return inspected.value;
        }
    }
    return value;
}

/**
 * @returns whether the given object is a promise.
 * Otherwise it is a fulfilled value.
 */
Q.isPromise = isPromise;
function isPromise(object) {
    return isObject(object) &&
        typeof object.promiseDispatch === "function" &&
        typeof object.inspect === "function";
}

Q.isPromiseAlike = isPromiseAlike;
function isPromiseAlike(object) {
    return isObject(object) && typeof object.then === "function";
}

/**
 * @returns whether the given object is a pending promise, meaning not
 * fulfilled or rejected.
 */
Q.isPending = isPending;
function isPending(object) {
    return isPromise(object) && object.inspect().state === "pending";
}

Promise.prototype.isPending = function () {
    return this.inspect().state === "pending";
};

/**
 * @returns whether the given object is a value or fulfilled
 * promise.
 */
Q.isFulfilled = isFulfilled;
function isFulfilled(object) {
    return !isPromise(object) || object.inspect().state === "fulfilled";
}

Promise.prototype.isFulfilled = function () {
    return this.inspect().state === "fulfilled";
};

/**
 * @returns whether the given object is a rejected promise.
 */
Q.isRejected = isRejected;
function isRejected(object) {
    return isPromise(object) && object.inspect().state === "rejected";
}

Promise.prototype.isRejected = function () {
    return this.inspect().state === "rejected";
};

//// BEGIN UNHANDLED REJECTION TRACKING

// This promise library consumes exceptions thrown in handlers so they can be
// handled by a subsequent promise.  The exceptions get added to this array when
// they are created, and removed when they are handled.  Note that in ES6 or
// shimmed environments, this would naturally be a `Set`.
var unhandledReasons = [];
var unhandledRejections = [];
var unhandledReasonsDisplayed = false;
var trackUnhandledRejections = true;
function displayUnhandledReasons() {
    if (
        !unhandledReasonsDisplayed &&
        typeof window !== "undefined" &&
        window.console
    ) {
        console.warn("[Q] Unhandled rejection reasons (should be empty):",
                     unhandledReasons);
    }

    unhandledReasonsDisplayed = true;
}

function logUnhandledReasons() {
    for (var i = 0; i < unhandledReasons.length; i++) {
        var reason = unhandledReasons[i];
        console.warn("Unhandled rejection reason:", reason);
    }
}

function resetUnhandledRejections() {
    unhandledReasons.length = 0;
    unhandledRejections.length = 0;
    unhandledReasonsDisplayed = false;

    if (!trackUnhandledRejections) {
        trackUnhandledRejections = true;

        // Show unhandled rejection reasons if Node exits without handling an
        // outstanding rejection.  (Note that Browserify presently produces a
        // `process` global without the `EventEmitter` `on` method.)
        if (typeof process !== "undefined" && process.on) {
            process.on("exit", logUnhandledReasons);
        }
    }
}

function trackRejection(promise, reason) {
    if (!trackUnhandledRejections) {
        return;
    }

    unhandledRejections.push(promise);
    if (reason && typeof reason.stack !== "undefined") {
        unhandledReasons.push(reason.stack);
    } else {
        unhandledReasons.push("(no stack) " + reason);
    }
    displayUnhandledReasons();
}

function untrackRejection(promise) {
    if (!trackUnhandledRejections) {
        return;
    }

    var at = array_indexOf(unhandledRejections, promise);
    if (at !== -1) {
        unhandledRejections.splice(at, 1);
        unhandledReasons.splice(at, 1);
    }
}

Q.resetUnhandledRejections = resetUnhandledRejections;

Q.getUnhandledReasons = function () {
    // Make a copy so that consumers can't interfere with our internal state.
    return unhandledReasons.slice();
};

Q.stopUnhandledRejectionTracking = function () {
    resetUnhandledRejections();
    if (typeof process !== "undefined" && process.on) {
        process.removeListener("exit", logUnhandledReasons);
    }
    trackUnhandledRejections = false;
};

resetUnhandledRejections();

//// END UNHANDLED REJECTION TRACKING

/**
 * Constructs a rejected promise.
 * @param reason value describing the failure
 */
Q.reject = reject;
function reject(reason) {
    var rejection = Promise({
        "when": function (rejected) {
            // note that the error has been handled
            if (rejected) {
                untrackRejection(this);
            }
            return rejected ? rejected(reason) : this;
        }
    }, function fallback() {
        return this;
    }, function inspect() {
        return { state: "rejected", reason: reason };
    });

    // Note that the reason has not been handled.
    trackRejection(rejection, reason);

    return rejection;
}

/**
 * Constructs a fulfilled promise for an immediate reference.
 * @param value immediate reference
 */
Q.fulfill = fulfill;
function fulfill(value) {
    return Promise({
        "when": function () {
            return value;
        },
        "get": function (name) {
            return value[name];
        },
        "set": function (name, rhs) {
            value[name] = rhs;
        },
        "delete": function (name) {
            delete value[name];
        },
        "post": function (name, args) {
            // Mark Miller proposes that post with no name should apply a
            // promised function.
            if (name === null || name === void 0) {
                return value.apply(void 0, args);
            } else {
                return value[name].apply(value, args);
            }
        },
        "apply": function (thisp, args) {
            return value.apply(thisp, args);
        },
        "keys": function () {
            return object_keys(value);
        }
    }, void 0, function inspect() {
        return { state: "fulfilled", value: value };
    });
}

/**
 * Converts thenables to Q promises.
 * @param promise thenable promise
 * @returns a Q promise
 */
function coerce(promise) {
    var deferred = defer();
    nextTick(function () {
        try {
            promise.then(deferred.resolve, deferred.reject, deferred.notify);
        } catch (exception) {
            deferred.reject(exception);
        }
    });
    return deferred.promise;
}

/**
 * Annotates an object such that it will never be
 * transferred away from this process over any promise
 * communication channel.
 * @param object
 * @returns promise a wrapping of that object that
 * additionally responds to the "isDef" message
 * without a rejection.
 */
Q.master = master;
function master(object) {
    return Promise({
        "isDef": function () {}
    }, function fallback(op, args) {
        return dispatch(object, op, args);
    }, function () {
        return Q(object).inspect();
    });
}

/**
 * Spreads the values of a promised array of arguments into the
 * fulfillment callback.
 * @param fulfilled callback that receives variadic arguments from the
 * promised array
 * @param rejected callback that receives the exception if the promise
 * is rejected.
 * @returns a promise for the return value or thrown exception of
 * either callback.
 */
Q.spread = spread;
function spread(value, fulfilled, rejected) {
    return Q(value).spread(fulfilled, rejected);
}

Promise.prototype.spread = function (fulfilled, rejected) {
    return this.all().then(function (array) {
        return fulfilled.apply(void 0, array);
    }, rejected);
};

/**
 * The async function is a decorator for generator functions, turning
 * them into asynchronous generators.  Although generators are only part
 * of the newest ECMAScript 6 drafts, this code does not cause syntax
 * errors in older engines.  This code should continue to work and will
 * in fact improve over time as the language improves.
 *
 * ES6 generators are currently part of V8 version 3.19 with the
 * --harmony-generators runtime flag enabled.  SpiderMonkey has had them
 * for longer, but under an older Python-inspired form.  This function
 * works on both kinds of generators.
 *
 * Decorates a generator function such that:
 *  - it may yield promises
 *  - execution will continue when that promise is fulfilled
 *  - the value of the yield expression will be the fulfilled value
 *  - it returns a promise for the return value (when the generator
 *    stops iterating)
 *  - the decorated function returns a promise for the return value
 *    of the generator or the first rejected promise among those
 *    yielded.
 *  - if an error is thrown in the generator, it propagates through
 *    every following yield until it is caught, or until it escapes
 *    the generator function altogether, and is translated into a
 *    rejection for the promise returned by the decorated generator.
 */
Q.async = async;
function async(makeGenerator) {
    return function () {
        // when verb is "send", arg is a value
        // when verb is "throw", arg is an exception
        function continuer(verb, arg) {
            var result;
            if (hasES6Generators) {
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    return reject(exception);
                }
                if (result.done) {
                    return result.value;
                } else {
                    return when(result.value, callback, errback);
                }
            } else {
                // FIXME: Remove this case when SM does ES6 generators.
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    if (isStopIteration(exception)) {
                        return exception.value;
                    } else {
                        return reject(exception);
                    }
                }
                return when(result, callback, errback);
            }
        }
        var generator = makeGenerator.apply(this, arguments);
        var callback = continuer.bind(continuer, "next");
        var errback = continuer.bind(continuer, "throw");
        return callback();
    };
}

/**
 * The spawn function is a small wrapper around async that immediately
 * calls the generator and also ends the promise chain, so that any
 * unhandled errors are thrown instead of forwarded to the error
 * handler. This is useful because it's extremely common to run
 * generators at the top-level to work with libraries.
 */
Q.spawn = spawn;
function spawn(makeGenerator) {
    Q.done(Q.async(makeGenerator)());
}

// FIXME: Remove this interface once ES6 generators are in SpiderMonkey.
/**
 * Throws a ReturnValue exception to stop an asynchronous generator.
 *
 * This interface is a stop-gap measure to support generator return
 * values in older Firefox/SpiderMonkey.  In browsers that support ES6
 * generators like Chromium 29, just use "return" in your generator
 * functions.
 *
 * @param value the return value for the surrounding generator
 * @throws ReturnValue exception with the value.
 * @example
 * // ES6 style
 * Q.async(function* () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      return foo + bar;
 * })
 * // Older SpiderMonkey style
 * Q.async(function () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      Q.return(foo + bar);
 * })
 */
Q["return"] = _return;
function _return(value) {
    throw new QReturnValue(value);
}

/**
 * The promised function decorator ensures that any promise arguments
 * are settled and passed as values (`this` is also settled and passed
 * as a value).  It will also ensure that the result of a function is
 * always a promise.
 *
 * @example
 * var add = Q.promised(function (a, b) {
 *     return a + b;
 * });
 * add(Q(a), Q(B));
 *
 * @param {function} callback The function to decorate
 * @returns {function} a function that has been decorated.
 */
Q.promised = promised;
function promised(callback) {
    return function () {
        return spread([this, all(arguments)], function (self, args) {
            return callback.apply(self, args);
        });
    };
}

/**
 * sends a message to a value in a future turn
 * @param object* the recipient
 * @param op the name of the message operation, e.g., "when",
 * @param args further arguments to be forwarded to the operation
 * @returns result {Promise} a promise for the result of the operation
 */
Q.dispatch = dispatch;
function dispatch(object, op, args) {
    return Q(object).dispatch(op, args);
}

Promise.prototype.dispatch = function (op, args) {
    var self = this;
    var deferred = defer();
    nextTick(function () {
        self.promiseDispatch(deferred.resolve, op, args);
    });
    return deferred.promise;
};

/**
 * Gets the value of a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to get
 * @return promise for the property value
 */
Q.get = function (object, key) {
    return Q(object).dispatch("get", [key]);
};

Promise.prototype.get = function (key) {
    return this.dispatch("get", [key]);
};

/**
 * Sets the value of a property in a future turn.
 * @param object    promise or immediate reference for object object
 * @param name      name of property to set
 * @param value     new value of property
 * @return promise for the return value
 */
Q.set = function (object, key, value) {
    return Q(object).dispatch("set", [key, value]);
};

Promise.prototype.set = function (key, value) {
    return this.dispatch("set", [key, value]);
};

/**
 * Deletes a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to delete
 * @return promise for the return value
 */
Q.del = // XXX legacy
Q["delete"] = function (object, key) {
    return Q(object).dispatch("delete", [key]);
};

Promise.prototype.del = // XXX legacy
Promise.prototype["delete"] = function (key) {
    return this.dispatch("delete", [key]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param value     a value to post, typically an array of
 *                  invocation arguments for promises that
 *                  are ultimately backed with `resolve` values,
 *                  as opposed to those backed with URLs
 *                  wherein the posted value can be any
 *                  JSON serializable object.
 * @return promise for the return value
 */
// bound locally because it is used by other methods
Q.mapply = // XXX As proposed by "Redsandro"
Q.post = function (object, name, args) {
    return Q(object).dispatch("post", [name, args]);
};

Promise.prototype.mapply = // XXX As proposed by "Redsandro"
Promise.prototype.post = function (name, args) {
    return this.dispatch("post", [name, args]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param ...args   array of invocation arguments
 * @return promise for the return value
 */
Q.send = // XXX Mark Miller's proposed parlance
Q.mcall = // XXX As proposed by "Redsandro"
Q.invoke = function (object, name /*...args*/) {
    return Q(object).dispatch("post", [name, array_slice(arguments, 2)]);
};

Promise.prototype.send = // XXX Mark Miller's proposed parlance
Promise.prototype.mcall = // XXX As proposed by "Redsandro"
Promise.prototype.invoke = function (name /*...args*/) {
    return this.dispatch("post", [name, array_slice(arguments, 1)]);
};

/**
 * Applies the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param args      array of application arguments
 */
Q.fapply = function (object, args) {
    return Q(object).dispatch("apply", [void 0, args]);
};

Promise.prototype.fapply = function (args) {
    return this.dispatch("apply", [void 0, args]);
};

/**
 * Calls the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q["try"] =
Q.fcall = function (object /* ...args*/) {
    return Q(object).dispatch("apply", [void 0, array_slice(arguments, 1)]);
};

Promise.prototype.fcall = function (/*...args*/) {
    return this.dispatch("apply", [void 0, array_slice(arguments)]);
};

/**
 * Binds the promised function, transforming return values into a fulfilled
 * promise and thrown errors into a rejected one.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q.fbind = function (object /*...args*/) {
    var promise = Q(object);
    var args = array_slice(arguments, 1);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};
Promise.prototype.fbind = function (/*...args*/) {
    var promise = this;
    var args = array_slice(arguments);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};

/**
 * Requests the names of the owned properties of a promised
 * object in a future turn.
 * @param object    promise or immediate reference for target object
 * @return promise for the keys of the eventually settled object
 */
Q.keys = function (object) {
    return Q(object).dispatch("keys", []);
};

Promise.prototype.keys = function () {
    return this.dispatch("keys", []);
};

/**
 * Turns an array of promises into a promise for an array.  If any of
 * the promises gets rejected, the whole array is rejected immediately.
 * @param {Array*} an array (or promise for an array) of values (or
 * promises for values)
 * @returns a promise for an array of the corresponding values
 */
// By Mark Miller
// http://wiki.ecmascript.org/doku.php?id=strawman:concurrency&rev=1308776521#allfulfilled
Q.all = all;
function all(promises) {
    return when(promises, function (promises) {
        var countDown = 0;
        var deferred = defer();
        array_reduce(promises, function (undefined, promise, index) {
            var snapshot;
            if (
                isPromise(promise) &&
                (snapshot = promise.inspect()).state === "fulfilled"
            ) {
                promises[index] = snapshot.value;
            } else {
                ++countDown;
                when(
                    promise,
                    function (value) {
                        promises[index] = value;
                        if (--countDown === 0) {
                            deferred.resolve(promises);
                        }
                    },
                    deferred.reject,
                    function (progress) {
                        deferred.notify({ index: index, value: progress });
                    }
                );
            }
        }, void 0);
        if (countDown === 0) {
            deferred.resolve(promises);
        }
        return deferred.promise;
    });
}

Promise.prototype.all = function () {
    return all(this);
};

/**
 * Waits for all promises to be settled, either fulfilled or
 * rejected.  This is distinct from `all` since that would stop
 * waiting at the first rejection.  The promise returned by
 * `allResolved` will never be rejected.
 * @param promises a promise for an array (or an array) of promises
 * (or values)
 * @return a promise for an array of promises
 */
Q.allResolved = deprecate(allResolved, "allResolved", "allSettled");
function allResolved(promises) {
    return when(promises, function (promises) {
        promises = array_map(promises, Q);
        return when(all(array_map(promises, function (promise) {
            return when(promise, noop, noop);
        })), function () {
            return promises;
        });
    });
}

Promise.prototype.allResolved = function () {
    return allResolved(this);
};

/**
 * @see Promise#allSettled
 */
Q.allSettled = allSettled;
function allSettled(promises) {
    return Q(promises).allSettled();
}

/**
 * Turns an array of promises into a promise for an array of their states (as
 * returned by `inspect`) when they have all settled.
 * @param {Array[Any*]} values an array (or promise for an array) of values (or
 * promises for values)
 * @returns {Array[State]} an array of states for the respective values.
 */
Promise.prototype.allSettled = function () {
    return this.then(function (promises) {
        return all(array_map(promises, function (promise) {
            promise = Q(promise);
            function regardless() {
                return promise.inspect();
            }
            return promise.then(regardless, regardless);
        }));
    });
};

/**
 * Captures the failure of a promise, giving an oportunity to recover
 * with a callback.  If the given promise is fulfilled, the returned
 * promise is fulfilled.
 * @param {Any*} promise for something
 * @param {Function} callback to fulfill the returned promise if the
 * given promise is rejected
 * @returns a promise for the return value of the callback
 */
Q.fail = // XXX legacy
Q["catch"] = function (object, rejected) {
    return Q(object).then(void 0, rejected);
};

Promise.prototype.fail = // XXX legacy
Promise.prototype["catch"] = function (rejected) {
    return this.then(void 0, rejected);
};

/**
 * Attaches a listener that can respond to progress notifications from a
 * promise's originating deferred. This listener receives the exact arguments
 * passed to ``deferred.notify``.
 * @param {Any*} promise for something
 * @param {Function} callback to receive any progress notifications
 * @returns the given promise, unchanged
 */
Q.progress = progress;
function progress(object, progressed) {
    return Q(object).then(void 0, void 0, progressed);
}

Promise.prototype.progress = function (progressed) {
    return this.then(void 0, void 0, progressed);
};

/**
 * Provides an opportunity to observe the settling of a promise,
 * regardless of whether the promise is fulfilled or rejected.  Forwards
 * the resolution to the returned promise when the callback is done.
 * The callback can return a promise to defer completion.
 * @param {Any*} promise
 * @param {Function} callback to observe the resolution of the given
 * promise, takes no arguments.
 * @returns a promise for the resolution of the given promise when
 * ``fin`` is done.
 */
Q.fin = // XXX legacy
Q["finally"] = function (object, callback) {
    return Q(object)["finally"](callback);
};

Promise.prototype.fin = // XXX legacy
Promise.prototype["finally"] = function (callback) {
    callback = Q(callback);
    return this.then(function (value) {
        return callback.fcall().then(function () {
            return value;
        });
    }, function (reason) {
        // TODO attempt to recycle the rejection with "this".
        return callback.fcall().then(function () {
            throw reason;
        });
    });
};

/**
 * Terminates a chain of promises, forcing rejections to be
 * thrown as exceptions.
 * @param {Any*} promise at the end of a chain of promises
 * @returns nothing
 */
Q.done = function (object, fulfilled, rejected, progress) {
    return Q(object).done(fulfilled, rejected, progress);
};

Promise.prototype.done = function (fulfilled, rejected, progress) {
    var onUnhandledError = function (error) {
        // forward to a future turn so that ``when``
        // does not catch it and turn it into a rejection.
        nextTick(function () {
            makeStackTraceLong(error, promise);
            if (Q.onerror) {
                Q.onerror(error);
            } else {
                throw error;
            }
        });
    };

    // Avoid unnecessary `nextTick`ing via an unnecessary `when`.
    var promise = fulfilled || rejected || progress ?
        this.then(fulfilled, rejected, progress) :
        this;

    if (typeof process === "object" && process && process.domain) {
        onUnhandledError = process.domain.bind(onUnhandledError);
    }

    promise.then(void 0, onUnhandledError);
};

/**
 * Causes a promise to be rejected if it does not get fulfilled before
 * some milliseconds time out.
 * @param {Any*} promise
 * @param {Number} milliseconds timeout
 * @param {String} custom error message (optional)
 * @returns a promise for the resolution of the given promise if it is
 * fulfilled before the timeout, otherwise rejected.
 */
Q.timeout = function (object, ms, message) {
    return Q(object).timeout(ms, message);
};

Promise.prototype.timeout = function (ms, message) {
    var deferred = defer();
    var timeoutId = setTimeout(function () {
        deferred.reject(new Error(message || "Timed out after " + ms + " ms"));
    }, ms);

    this.then(function (value) {
        clearTimeout(timeoutId);
        deferred.resolve(value);
    }, function (exception) {
        clearTimeout(timeoutId);
        deferred.reject(exception);
    }, deferred.notify);

    return deferred.promise;
};

/**
 * Returns a promise for the given value (or promised value), some
 * milliseconds after it resolved. Passes rejections immediately.
 * @param {Any*} promise
 * @param {Number} milliseconds
 * @returns a promise for the resolution of the given promise after milliseconds
 * time has elapsed since the resolution of the given promise.
 * If the given promise rejects, that is passed immediately.
 */
Q.delay = function (object, timeout) {
    if (timeout === void 0) {
        timeout = object;
        object = void 0;
    }
    return Q(object).delay(timeout);
};

Promise.prototype.delay = function (timeout) {
    return this.then(function (value) {
        var deferred = defer();
        setTimeout(function () {
            deferred.resolve(value);
        }, timeout);
        return deferred.promise;
    });
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided as an array, and returns a promise.
 *
 *      Q.nfapply(FS.readFile, [__filename])
 *      .then(function (content) {
 *      })
 *
 */
Q.nfapply = function (callback, args) {
    return Q(callback).nfapply(args);
};

Promise.prototype.nfapply = function (args) {
    var deferred = defer();
    var nodeArgs = array_slice(args);
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided individually, and returns a promise.
 * @example
 * Q.nfcall(FS.readFile, __filename)
 * .then(function (content) {
 * })
 *
 */
Q.nfcall = function (callback /*...args*/) {
    var args = array_slice(arguments, 1);
    return Q(callback).nfapply(args);
};

Promise.prototype.nfcall = function (/*...args*/) {
    var nodeArgs = array_slice(arguments);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Wraps a NodeJS continuation passing function and returns an equivalent
 * version that returns a promise.
 * @example
 * Q.nfbind(FS.readFile, __filename)("utf-8")
 * .then(console.log)
 * .done()
 */
Q.nfbind =
Q.denodeify = function (callback /*...args*/) {
    var baseArgs = array_slice(arguments, 1);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        Q(callback).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nfbind =
Promise.prototype.denodeify = function (/*...args*/) {
    var args = array_slice(arguments);
    args.unshift(this);
    return Q.denodeify.apply(void 0, args);
};

Q.nbind = function (callback, thisp /*...args*/) {
    var baseArgs = array_slice(arguments, 2);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        function bound() {
            return callback.apply(thisp, arguments);
        }
        Q(bound).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nbind = function (/*thisp, ...args*/) {
    var args = array_slice(arguments, 0);
    args.unshift(this);
    return Q.nbind.apply(void 0, args);
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback with a given array of arguments, plus a provided callback.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param {Array} args arguments to pass to the method; the callback
 * will be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nmapply = // XXX As proposed by "Redsandro"
Q.npost = function (object, name, args) {
    return Q(object).npost(name, args);
};

Promise.prototype.nmapply = // XXX As proposed by "Redsandro"
Promise.prototype.npost = function (name, args) {
    var nodeArgs = array_slice(args || []);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback, forwarding the given variadic arguments, plus a provided
 * callback argument.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param ...args arguments to pass to the method; the callback will
 * be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nsend = // XXX Based on Mark Miller's proposed "send"
Q.nmcall = // XXX Based on "Redsandro's" proposal
Q.ninvoke = function (object, name /*...args*/) {
    var nodeArgs = array_slice(arguments, 2);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    Q(object).dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

Promise.prototype.nsend = // XXX Based on Mark Miller's proposed "send"
Promise.prototype.nmcall = // XXX Based on "Redsandro's" proposal
Promise.prototype.ninvoke = function (name /*...args*/) {
    var nodeArgs = array_slice(arguments, 1);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * If a function would like to support both Node continuation-passing-style and
 * promise-returning-style, it can end its internal promise chain with
 * `nodeify(nodeback)`, forwarding the optional nodeback argument.  If the user
 * elects to use a nodeback, the result will be sent there.  If they do not
 * pass a nodeback, they will receive the result promise.
 * @param object a result (or a promise for a result)
 * @param {Function} nodeback a Node.js-style callback
 * @returns either the promise or nothing
 */
Q.nodeify = nodeify;
function nodeify(object, nodeback) {
    return Q(object).nodeify(nodeback);
}

Promise.prototype.nodeify = function (nodeback) {
    if (nodeback) {
        this.then(function (value) {
            nextTick(function () {
                nodeback(null, value);
            });
        }, function (error) {
            nextTick(function () {
                nodeback(error);
            });
        });
    } else {
        return this;
    }
};

// All code before this point will be filtered from stack traces.
var qEndingLine = captureLine();

return Q;

});

define('src/cs-localstore',['src/csbase', 'src/csutil', 'node_modules/q/q'], function(CS, Util, Q) {

	/*
	 * Constants
	 */
	var ASCENDING = 'ascending',
		DESCENDING = 'descending',

		SESSION_DATA_KEY = 'SessionData',

		SFDC_METADATA_SOUP = 'SfdcMetadata',
		LOCAL_METADATA_SOUP = 'LocalMetadata',
		STATIC_RESOURCE_SOUP = 'StaticResource',
		STATIC_RESOURCE_DATA_SOUP = 'StaticResourceData',

		SOBJECT_INDEX_SPEC = [
			{path: 'Id', type: 'string'},
			{path: 'name', type: 'string'} // smartstore requires 'name' path to be lowercase
		],

		smartstore = navigator.smartstore;

	if (!smartstore) {
		CS.Log.warn('SmartStore dependency not found on navigator object - has cordova.force.js been loaded?');
		return {};
	}

	function closeCursor(cursor) {
		smartstore.closeCursor(cursor, function() {}, function(e) {CS.Log.error('Cusor could not be closed: ' + e);});
	}

	function cursorHasMorePages(cursor) {
		return cursor.currentPageIndex < cursor.totalPages - 1;
	}

	function iterateCursor(cursor, f, acc) {
		var d = Q.defer();
		doIteration(cursor, f, acc);
		return d.promise;

		function doIteration(cursor, f, acc) {
			if (!acc) {
				acc = {};
			}
			f(cursor, acc);
			if (cursorHasMorePages(cursor)) {
				smartstore.moveCursorToNextPage(cursor, 
					function(c2)  {
						d.promise.then(doIteration(c2, f, acc));
					},
					function(c, e) {
						d.reject(e);
						closeCursor(c);
					}
				);
			} else {
				d.resolve(acc);
				closeCursor(cursor);
			}
		}
	}

	/**
		@memberOf CS.LocalStore
		@public
		@constructor
	*/
	function QueryResult(cursor) {
		this.cursor = cursor;
	}

	/**
		Returns a promise for all the objects selected by the query,
		iterating through the custor pages and closing the cursor automatically.
		The promise returns an Array of the objects, or if the indexPath parameter
		is specified it returns a Map of the objects, keyed by the field
		identified by the indexPath.

		@param 	[indexPath:String]		a field on the objects to use as keys in
										the Map of results
	*/
	QueryResult.prototype.getAll = function getAll(indexPath, pageSize) {
		var d = Q.defer(),
			self = this,
			acc = indexPath ? {} : [];

		if (!this.cursor) {
			throw new Error('No cursor available');
		}

		iterateCursor(this.cursor, function(cursor, acc) {
			var entries = cursor.currentPageOrderedEntries;
			if (indexPath) {
				_.extend(acc, _.indexBy(entries, indexBy));
			} else {
				acc.push.apply(acc, entries);
			}
		}, acc)
		.then(function(result) {
			d.resolve(result);
		})
		.fail(function(e) {
			Log.error('QueryResult.getAll', indexPath, e);
			d.reject(e);
		});

		return d.promise;
	};

	/**
		Returns the SmartStore cursor backing this QueryResult, which can be manipulated
		directly as needed.
	*/	
	QueryResult.prototype.getCursor = function getCursor() {
		return this.cursor;
	};

	/**
		Closes the cursor wrapped by this QueryResult. No further objects can be retrieved
		once the cursor is closed.
	*/
	QueryResult.prototype.closeCursor = function _closeCursor() { // avoid name shadowing with LocalStore.closeCursor
		closeCursor(this.cursor);
		this.cursor = undefined;
	};

	function LocalStore() {

	}

	/**
	 * Returns a promise for the creation of a new store for local data.
	 * Fails with message 'Store exists' if a store with the same name exists.
	 */
	LocalStore.prototype.createStore = function(name, indexSpec) {
		// query metadata for existng object
		// if exists, compare spec
		// if changed - flag change (spec update todo)
		// otherwise create soup
		var self = this;

		Log.debug('createStore: ', name, indexSpec);
		if (!indexSpec) {
			Log.info('No indexSpec provided');
			return Q.reject('No indexSpec provided to create table ' + name);
		}

		return this.getMetadataForStore(name)
			.then(function(data) {
				Log.debug('Checking store name ', name);
				if (data) {
					Log.info('Store ', name, ' exists, will not try to register');
					return Q(true);
				} else {
					return Q(false);					
				}
			})
			.then(function(exists) {
				Log.info('Soup', name, 'exists: ' + exists);
				if (!exists) {
					Log.info('About to register soup, ', name, indexSpec);
					return self.registerSoup(name, indexSpec)
						.then(function() {
							return self.upsert(LOCAL_METADATA_SOUP, {Id: name, indexSpec: indexSpec}, 'Id');
						});
				} else {
					return Q(false);
				}
			});
	};


	LocalStore.prototype.createStoreForSfdcObject = function(name, tableSpec, describe) {
		var i,
			allFields = [],
			sfdcFields = [],
			field,
			fieldDml = '',
			defs = {};

		Log.info('Creating store for SFDC object ' + name);

		try {
			for (i = 0; i < describe.fields.length; i++) {
				field = describe.fields[i].name;
				if (field) {
					sfdcFields.push(field);
					allFields.push(field);
				}
			}
			tableSpec.sfdcFields = sfdcFields;
			if (tableSpec.offlineFields) {
				for (i = 0; i < tableSpec.offlineFields.length; i++) {
					field = tableSpec.offlineFields[i];
					if (typeof field === 'object') {
						allFields.push(field.name);
						defs[field.name] = field.def;
					} else {
						allFields.push(field);										
					}
				}
			}
			tableSpec.allFields = allFields;
		} catch (e) {
			Log.warn(e);
		}

		if (!tableSpec.indexSpec) {
			Log.info('No indexSpec for table ' + name);
			return Q.reject('No indexSpec for table ' + name);
		}
		
		if (CS.DB._existingTables[name]) {
			Log.debug('Table ' + name + ' exists');
			return Q.resolve('Table ' + name + ' exists');
		} else {
			Log.info('Creating table ' + name);
			var indexSpec = mergeSpecs(SOBJECT_INDEX_SPEC, tableSpec.indexSpec);
			return this.createStore(name, indexSpec)
				.fail(function(e) {
					if (e == 'Store exists') {
						Log.info('Skipping, store ', name, ' exists....');
						return Q.resolve('Table ' + name + ' exists');
					} else {
						throw e;
					}
				});
		}
	};

	/**
	 * Delete records from the specified soup with _soupEntryIds matching the supplied list
	 */
	LocalStore.prototype.delete = function _delete(soupName, soupEntryIds) {
		var d = Q.defer();

		smartstore.removeFromSoup(
			soupName,
			soupEntryIds,
			function success() {
				d.resolve('Entries deleted: ' + soupEntryIds.length);
			},
			function error(err) {
				if (!err) {
					err = {};
				}
				Log.error('Could not delete entries in ' + soupName + ' with soupEntryIds ' + soupEntryIds, err.message, err);
				d.reject('Could not delete entries in ' + soupName + ': ' + err.message);
			}
		);
		return d.promise;
			
	};

	/**
	 * Remove records from the speificied soup matching the indexPath/value
	 * TODO This method should be renamed to removeBy
	 * To delete a set of records by _soupEntryId, use delete
	 */
	LocalStore.prototype.remove = function remove(soupName, indexPath, value) {
		var self = this;
		return this.findBy(soupName, indexPath, value)
			.then(function(qr) {
				return qr.getAll();
			})
			.then(function(records) {
				if (records.length === 0) {
					return Q.reject('No matching records found in ' + soupName + ' for indexPath ' + indexPath + ' with value ' + value);
				} else {
					self.delete(soupName, _.pluck(records, '_soupEntryId'));
				}
			});
	};

	/**
	 * Merge the indexSpec definitions in arrays x and y
	 * array y will override entries with matching paths in array x
	 * so treat array x as the default set, to be expanded/overriden by y.
	 */
	function mergeSpecs(x, y) {
		var z = [].concat(y),
			keys = {};
		_.each(y, function (it) {
			keys[it.path] = it.type
		});
		_.each(x, function (it) {
			if (!keys[it.path]) {
				z.push(it);
			}
		});
		return z;
	}

	/**
	 * Returns a promise for all the records in the store, either as a QueryResult
	 * (if pageSize is specified) or an array of all the records (if pageSize is not specified)
	 */
	LocalStore.prototype.getAll = function getAll(soupName, indexPath, order, pageSize) {
		var d = Q.defer();
		if (!indexPath) {
			indexPath = '_soupEntryId';
		}

		this.storeExists(soupName)
		.then(function(exists) {
			if (exists) {
				try {
					var querySpec = smartstore.buildAllQuerySpec(indexPath, order, pageSize || 100);
					smartstore.querySoup(soupName, querySpec,
						function(cursor) {
							if (!pageSize) {
								d.resolve(new QueryResult(cursor).getAll());
							} else {
								d.resolve(new QueryResult(cursor));
							}
						},
						function(e) {
							Log.error('Error in LocalStore.getAll: ', soupName, e.message, e);
							d.reject(e.message);
						}
					);
				} catch (e) {
					Log.error('Error in getAll:', e.message, e);
					d.reject(e.message);
				}
			} else {
				d.resolve([]);
			}
		});

		return d.promise;
	};

	LocalStore.prototype.getAllStaticResources = function getAllStaticResources() {
		var d = Q.defer();

		try {
			var querySpec = smartstore.buildSmartQuerySpec(
				"SELECT {StaticResource:_soup}, {StaticResourceData:_soup} FROM {StaticResource}, {StaticResourceData} WHERE {StaticResource:Id} = {StaticResourceData:Id}"
			);
			smartstore.runSmartQuery(querySpec,
				function(cursor) {
					return new QueryResult(cursor)
							.getAll()
							.then(function(rows) {
								var results = [];
								_.each(rows, function(it) {
									var result = _.extend({}, it[0]);
									try {
										result.Data = JSON.parse(it[1]).Data;
										results.push(result);
									} catch (e) {
										Log.error('Could not parse Static Resource', result.Name, e.message, e);
										d.reject(e);
									}
								});
								d.resolve(results);
							});
				},
				function(e) {
					if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
						Log.info(e.message);
						d.resolve({});
					} else {
						d.reject(e);
					}
				}
			);
		} catch (e) {
			if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
				Log.info(e.message);
				d.resolve({});
			} else {
				d.reject(e);
			}
		}

		return d.promise;		
	};

	/**
	 * Returns a promise for all records from the store matching the indexPath and value
	 */
	LocalStore.prototype.findBy = function(soupName, indexPath, value, pageSize) {
		var d = Q.defer();
		Log.debug('LocalStore.findBy', soupName, indexPath, value);
		try {
			var querySpec = smartstore.buildExactQuerySpec(indexPath, value, pageSize || 10);
			smartstore.querySoup(soupName, querySpec,
				function(cursor) {
					d.resolve(new QueryResult(cursor));
				}
			);
		} catch (e) {
			d.reject(e);
		}

		return d.promise;
	};

	/**
	 * Returns a promise for the record from the store matching the indexPath and value
	 */
	LocalStore.prototype.getBy = function(soupName, indexPath, value, pageSize) {
		var d = Q.defer();
		Log.debug('LocalStore.getBy', soupName, indexPath, value);
		if (value === undefined) {
			d.reject('LocalStore.getBy value cannot be undefined');
		} else {
			this.storeExists(soupName)
			.then(function(exists) {
				if (exists) {
					try {
						var querySpec = smartstore.buildExactQuerySpec(indexPath, value, pageSize || 10);
						smartstore.querySoup(soupName, querySpec,
							function(cursor) {
								if (cursor.currentPageOrderedEntries.length > 0) {
									d.resolve(cursor.currentPageOrderedEntries[0]);
								} else {
									d.resolve(undefined);
								}
								closeCursor(cursor);
							}
						);
					} catch (e) {
						d.reject(e);
					}
				}
			});
		}

		return d.promise;
	};

	LocalStore.prototype.getLastSyncDate = function() {
		return CS.DB.getBy('SfdcMetadata', 'Id', 'LastSyncDate')
		.then(function(r) {
			if (r) {
				return Q.resolve(new Date(r.Date));
			}
			return Q.resolve(undefined);
		});
	};

	LocalStore.prototype.getLocalConfig = function() {
		var d = Q.defer();

		try {
			var querySpec = smartstore.buildSmartQuerySpec(
				"SELECT {StaticResource:_soup}, {StaticResourceData:_soup} FROM {StaticResource}, {StaticResourceData} WHERE {StaticResource:Id} = {StaticResourceData:Id} AND {StaticResource:name} = 'CloudSense_Anywhere_Config'"
			);
			smartstore.runSmartQuery(querySpec,
				function(cursor) {
					if (cursor.currentPageOrderedEntries.length) {
						var json = cursor.currentPageOrderedEntries[0];
						d.resolve(JSON.parse(JSON.parse(json[1]).Data));
					} else {
						CS.Log.error('No local config found');
						d.resolve({});
					}
					closeCursor(cursor);
				},
				function(e) {
					if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
						Log.info(e.message);
						d.resolve({});
					} else {
						d.reject(e);
					}
				}
			);
		} catch (e) {
			if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
				Log.info(e.message);
				d.resolve({});
			} else {
				d.reject(e);
			}
		}

		return d.promise;		
	};

	LocalStore.prototype.getMetadataForAllStores = function(pageSize) {
		var d = Q.defer();
		try {
			Log.info('getMetadataForAllStores');
			var querySpec = smartstore.buildAllQuerySpec('Id', ASCENDING, pageSize),
				stores = {};
			smartstore.querySoup(LOCAL_METADATA_SOUP, querySpec, function(cursor) {
				iterateCursor(cursor, function(cursor, acc) {
					_.extend(acc, _.indexBy(cursor.currentPageOrderedEntries, 'Id'));
				})
				.then(function(result) {
					d.resolve(result);
				})
				.fail(function(e) {
					d.reject(e);
				});
			});
		} catch (e) {
			d.reject(e);
		}

		return d.promise;
	};

	LocalStore.prototype.getMetadataForStore = function(name) {
		var d = Q.defer();
		try {
			Log.debug('getMetadataForStore', name);
			return this.getBy(LOCAL_METADATA_SOUP, 'Id', name);
		} catch (e) {
			Log.info('Error getting metadata for store', name, e);
			d.reject(e);
		}

		return d.promise;
	};

	LocalStore.prototype.getSessionData = function() {
		return this.getBy(SFDC_METADATA_SOUP, 'Id', SESSION_DATA_KEY)
			.fail(function() {
				Log.debug('No stored session data found');
				// no problem
			});
	};

	/**
	 * Sets up system data storage for StaticResource and Metadata
	 */
	LocalStore.prototype.init = function(orgId) {
		var self = CS.LocalStore || this; // still confused about window scope here
		return Q.all([
			self.registerSoup(LOCAL_METADATA_SOUP, metadataIndexSpec),
			self.registerSoup(SFDC_METADATA_SOUP, metadataIndexSpec),
			self.registerSoup(STATIC_RESOURCE_SOUP, staticResourceIndexSpec),
			self.registerSoup(STATIC_RESOURCE_DATA_SOUP, staticResourceDataIndexSpec)
		]);
	};

	LocalStore.prototype.removeMetadata = function() {
		var self = CS.LocalStore; // TODO WTF why are we in window scope here??
		return self.removeStore(SFDC_METADATA_SOUP)
			.then(function() {
				self.removeStore(LOCAL_METADATA_SOUP);
			})
			.then(function() {
				self.removeStore(STATIC_RESOURCE_SOUP);
			})
			.then(function() {
				self.removeStore(STATIC_RESOURCE_DATA_SOUP);
			});
	};

	LocalStore.prototype.removeStore = function removeStore(name) {
		var d = Q.defer();
		Log.debug('removeStore: ', name);
		try {
			smartstore.removeSoup(name,
				function() {
					var m = 'Soup ' + name + ' removed';
					Log.info(m);
					d.resolve(m);
				},
				function(e) {
					Log.error('Could not remove store: ', e);
					d.reject(e);
				}
			);
		} catch (e) {
			d.reject(e);
		}
		return d.promise;
	};

	/**
	 * Returns a promise to create a new soup direct in SmartStore.
	 * If the soup already exists, the promise is fulfilled.
	 * This method should not be used directly unless specifically required.
	 * See createLocalStore() instead for proper maintaineance of local metadata.
	 */
	LocalStore.prototype.registerSoup = function(name, indexSpec) {
		var d = Q.defer(),
			realSpec = _.map(indexSpec, function(it) {
				var spec = {path: it.path, type: it.type};
				if (spec.path === 'Name') {
					spec.path = 'name';
				}
				return spec;
			});

		Log.debug('Registering soup: ', name, realSpec);
		navigator.smartstore.registerSoup(name, realSpec,
			function(result) {
				Log.info('Registered soup', name);
				d.resolve(result);
			}, function(e) {
				Log.info('Could not register soup', e);
				d.reject(e);
			}
		);
		return d.promise;
	};

	LocalStore.prototype.setLastSyncDate = function(date) {
		return CS.DB.upsert('SfdcMetadata', [{Id: 'LastSyncDate', Date: date}], 'Id');
	};

	LocalStore.prototype.setSessionData = function(data) {
		var record = _.extend({Id: SESSION_DATA_KEY}, data);
		Log.info('setSessionData:', record);
		return this.upsert(SFDC_METADATA_SOUP, record, 'Id');
	};

	LocalStore.prototype.smartQuery = function(query, pSize) {
		var d = Q.defer(),
			pageSize = pSize || 10;

		try {
			var querySpec = smartstore.buildSmartQuerySpec(query, pageSize);
			smartstore.runSmartQuery(querySpec,
				function(cursor) {
					d.resolve(new QueryResult(cursor));
				}, 
				function(e) {
					if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
						Log.info(e.message);
						d.resolve(new QueryResult({cursorId: -1, soupName: 'Unknown', querySpec: querySpec, pageSize: pageSize, currentPageIndex: 0, currentPageOrderedEntries: [], totalPages: 0}));
					} else {
						d.reject(e);
					}
				}
			);
		} catch (e) {
			if (e.message && Util.startsWith(e.message, 'SmartQuery not supported by MockSmartStore')) {
				Log.info(e.message);
				d.resolve({});
			} else {
				d.reject(e);
			}
		}

		return d.promise;		
	};

	LocalStore.prototype.storeExists = function storeExists(name) {
		var d = Q.defer();
		smartstore.soupExists(name, function(exists) {
			d.resolve(exists);
		}, function(e) {
			Log.error('Error in smartstore.soupExists()', e.message, e);
			d.reject(e);
		});

		return d.promise;
	};

	LocalStore.prototype.storeStaticResource = function storeStaticResource(header, data) {
		var self = this;
		return self.upsert(STATIC_RESOURCE_SOUP, header, 'Id')
			.then(function() {
				var payload = {Id: header.Id, Data: data};
				Log.debug('Storing StaticResourceData', payload.Id);
				return self.upsert(STATIC_RESOURCE_DATA_SOUP, payload, 'Id');
			})
			.fail(function(e) {
				Log.error('Could not store StaticResource', e.message, e);
				throw e;
			});
	};

	/**
	 * Returns a promise to insert the supplied object into the named soup.
	 */
	LocalStore.prototype.upsert = function(soupName, data, keyPath) {
		var d = Q.defer(),
			extId = keyPath && keyPath === 'Name' ? 'name' : keyPath,
			payload = data && Array.isArray(data) ? data : [data];
		
		_.each(payload, function(it) {
			if (it.Name) {
				it.name = it.Name; // SmartStore does not seem to handle capitalised 'Name' path
			}
		});
		if (!data) {
			d.reject('Supplied record for upsert is null');
		} else {
			if (extId) {
				smartstore.upsertSoupEntriesWithExternalId(soupName, payload, extId,
					function(result) {
						d.resolve(result);
					},
					function (e) {
						d.reject(e);
					}
				);
			} else {
				smartstore.upsertSoupEntries(soupName, payload,
					function(result) {
						d.resolve(result);
					},
					function (e) {
						d.reject(e);
					}
				);
			}				
		}

		return d.promise;
	};

	var Log = CS.Log,
		staticResourceIndexSpec = [
			{path: 'Id', type: 'string'},
			{path: 'name', type: 'string'}
		],
		staticResourceDataIndexSpec = [
			{path: 'Id', type: 'string'}
		],
		metadataIndexSpec = [
			{path: 'Id', type: 'string'}
		];

	return new LocalStore();

});

/* Cursor object structure:

{
  cursorId: 3,
  soupName: 'LocalMetadata',
  querySpec: {
    queryType: 'range',
    indexPath: 'name',
    matchKey: null,
    likeKey: null,
    beginKey: null,
    endKey: null,
    smartSql: null,
    order: 'ascending',
    pageSize: 10
  },
  pageSize: 10,
  currentPageIndex: 0,
  currentPageOrderedEntries: [
    ...
  ],
  totalPages: 1
}
*/;
define('src/cs-sfdc',['src/csbase', 'src/cs-database', 'node_modules/q/q'], function(CS, DB, Q) {

	var Log = CS.Log; //.prefix('CS.SFDC');
	
	function SFDC() {
		this.client = undefined;
		this.userId = undefined;
	}

	SFDC.prototype.apexRest = function(path, method, payload, headerParams) {
		var d = Q.defer();

		this.client.apexrest(path, method, payload, headerParams, restSuccess, restError);

		function restSuccess(json) {
			return d.resolve(json);
		}

		function restError(xhr, status, code) {
			var e = {
				ajaxStatus: status
			};

			try {
				var response = JSON.parse(xhr.responseText)[0];
				e.message = xhr.status + ' ' + (e.errorCode ? response.errorCode + ' ' : '') + response.message;
			} catch (err) {
				e.message = xhr.status + ' ' + xhr.responseText;
			}
			return d.reject(e);
		}

		return d.promise;
	};

	SFDC.prototype.create = function(sObjectType, fields) {
		var d = Q.defer();
		Log.info('create:', sObjectType);
		this.client.create(sObjectType, fields,
			function success(result) {
				Log.info('Created ', sObjectType);
				d.resolve(result);
			}, function error(jqXHR, textStatus, errorThrown) {
				Log.error('Could not create ', sObjectType, errorThrown);
				d.reject(errorThrown);
			}
		);
		return d.promise;
	};

	SFDC.prototype.getDescribe = function(tableName) {
		var d = Q.defer();
		Log.info('getSfdcDescribe: ' + tableName);
		this.client.describe(tableName,
			function success(result) {
				Log.info('Got describe for ' + tableName);
				d.resolve(result);
			}, function error(jqXHR, textStatus, errorThrown) {
				Log.error('Describe error: ', errorThrown);
				d.reject(errorThrown, 'Describe ' + tableName);
			}
		);
		return d.promise;
	};

	SFDC.prototype.getSessionData = function() {
		var sessionData = {},
			sessionId = this.client.sessionId,
			orgId;
		if (sessionId && sessionId.indexOf('!') > -1) {
			orgId = sessionId.substring(0, sessionId.indexOf('!'));
		}
		sessionData.sessionId = sessionId;
		sessionData.orgId = orgId;
		sessionData.userId = this.userId; // TODO - integrate with regular SFDC OAuth
		sessionData.userProfileId = undefined; //TODO

		Log.info('getSessionData:', sessionData);
		return sessionData;
	};

	SFDC.prototype.hasOrgIdChanged = function(lastOrgId) {
		var sessionData = this.getSessionData(),
			orgId = sessionData ? sessionData.orgId : undefined;
		Log.info('Has Org ID changed? Current: ' + lastOrgId + ' / New: ' + orgId);
		return (lastOrgId && orgId != lastOrgId);
	};

	SFDC.prototype.query = function query() {
		this.client.query.apply(this.client, arguments);
	};

	SFDC.prototype.queryMore = function queryMore() {
		this.client.queryMore.apply(this.client, arguments);
	};

	SFDC.prototype.reset = function() {
		// clear describe caches etc
	};

	SFDC.prototype.retrieve = function retrieve() {
		this.client.retrieve.apply(this.client, arguments);
	};

	/*
	 * Retrieves SFDC binary body data (e.g. for static resources, attachments) for a record of the given type.
	 * Requires an active ForceTK Client instance.
	 * @param client an active ForceTK client instance
	 * @param objtype object type; e.g. "StaticResource"
	 * @param id the record's object ID
	 * @param callback function to which response will be passed
	 * @param [error=null] function to which jqXHR will be passed in case of error
	 */
	SFDC.prototype.retrieveBinary = function retrieveBinary(objtype, id, callback, error) {
		var path = '/' + this.client.apiVersion + '/sobjects/' + objtype + '/' + id + '/Body',
			url = this.client.instanceUrl + '/services/data' + path;

		var xhr = new XMLHttpRequest();
		xhr.open('GET', url, true);
		xhr.responseType = 'arraybuffer';

		if (this.client.proxyUrl !== null) {
			xhr.setRequestHeader('SalesforceProxy-Endpoint', url);
		}
		xhr.setRequestHeader(this.client.authzHeader, "Bearer " + this.client.sessionId);
		xhr.setRequestHeader('X-User-Agent', 'cs-javascript/' + this.client.apiVersion);

		if (this.client.userAgentString !== null) {
			xhr.setRequestHeader('User-Agent', this.client.userAgentString);
		}

		xhr.onreadystatechange = function(e) {
			if (this.readyState == 4) {
				if (this.status == 200) {
					callback(this);
				} else {
					if (error) {
						error(this);
					} else {
						throw(this);
					}
				}
			}
		};

		xhr.send();
	};

	SFDC.prototype.setClient = function(client) {
		this.reset();
		this.client = client;
	};

	// For use when integrated to external auth mechanism
	SFDC.prototype.setUserId = function(userId) {
		this.userId = userId;
	};

	return new SFDC();

});
/**
	@memberOf CS
	@requires Base
	@requires Util
	@requires LocalStore
	@requires SFDC
	@requires Q
*/
define('src/cs-database',[
		'src/csbase',
		'src/csutil',
		'src/cs-localstore',
		'src/cs-sfdc',
		'node_modules/q/q'
	], function(CS, Util, LocalStore, SFDC, Q) {

	var BIN = 'bin',
		TXT = 'txt',
		CONTENT_TYPES = {
		'application/json': TXT,
		'application/zip': BIN,
		'image/gif': BIN,
		'image/jpeg': BIN,
		'image/png': BIN,
		'text/plain': TXT
		},
		
		REMOTE_CONFIG_NAME = 'CloudSense_Anywhere_Config',

		prefix = Util.configuratorPrefix,

		standardTables = {
			Account: {
				label: 'Account',
				labelPlural: 'Accounts',
				offlineFields: ['Updated', 'LastAccessDate'],
				indexSpec: [
					{path: 'Id', type: 'string'}
				],
				sfdc: true,
				standard: true
			},
			Attachment: {
				label: 'Attachment',
				labelPlural: 'Attachments',
				offlineFields: ['RelatedSoup', 'RelatedEntryId', 'Name', 'ContentType', 'Url', 'Data'],
				indexSpec: [
					{path: 'RelatedEntryId', type: 'integer'},
					{path: 'RelatedSoup', type: 'string'},
					{path: 'Name', type: 'string'},
					{path: 'ContentType', type: 'string'}
				],
				standard: true
			},
			Contact: {
				label: 'Contact',
				labelPlural: 'Contacts',
				offlineFields: ['Updated'],
				indexSpec: [
					{path: 'Id', type: 'string'},
					{path: 'AccountId', type: 'string'}
				],
				sfdc: true,
				standard: true
			},
			Configuration: {
				isUGC: true,
				offlineFields: ['cscfga__Product_Basket__c', 'Json'],
				indexSpec: [
					{path: 'cscfga__Product_Basket__c', type: 'string'}
				],
				standard: true
			},
			cscfga__Product_Basket__c: {
				customSync: true,
				label: 'Product Basket',
				labelPlural: 'Product Baskets',
				isUGC: true,
				offlineFields: ['cfgoffline__Account__c', 'Uploaded', 'LastAccessDate','PdfUrl', 'UploadMessage'],
				indexSpec: [
					{path: 'Id', type: 'string'}
				],
				sfdc: true,
				standard: true
			},
			cscfga__Product_Category__c: {
				filter: prefix + 'Active__c = true AND cfgoffline__Include_Offline__c = true',
				label: 'Product Category',
				labelPlural: 'Product Categories',
				offlineFields: ['Updated'],
				indexSpec: [
					{path: 'Id', type: 'string'},
					{path: 'cscfga__Parent_Category__c', type: 'string'},
					{path: 'cscfga__Browseable__c', type: 'string'}
				],
				sfdc: true,
				standard: true
			},
			cscfga__Product_Definition__c: {
				filter: prefix + 'Active__c = true AND cfgoffline__Include_Offline__c = true',
				label: 'Product Definition',
				labelPlural: 'Product Definitions',
				offlineFields: ['Updated'],
				indexSpec: [
					{path: 'Id', type: 'string'},
					{path: 'cscfga__Product_Category__c', type: 'string'}
				],
				sfdc: true,
				standard: true
			},
			Product_Model: {
				offlineFields: ['Id', 'Data'],
				indexSpec: [
					{path: 'Id', type: 'string'}
				],
				standard: true
			},
			Product_Template: {
				offlineFields: ['Id', 'Data'],
				indexSpec: [
					{path: 'Id', type: 'string'}
				],
				standard: true
			}
		};



	/*
	 * 1. Init
	 * Create Metadata table if not present
	 * Load existing tables and config from Metadata
	 * 
	 * 2. Refresh SFDC Metadata
	 * Get config - compare mod date with previous, reparse & update if newer
	 * Get describes
	 *
	 * 3. Update Product Catalogue
	 * Get config - compare mode date with previous, do 2. Refresh SFDC Metadata if newer
	 * Iterate through tables as usual
	 */

	function applyConfig(config) {
/*		var oldConfigUpdated = CS.DB.config && CS.DB.config.Updated ? new Date(CS.DB.config.Updated) : undefined,
			newConfigUpdated = config.LastModifiedDate ? CS.DB.parseDate(config.LastModifiedDate) : config.Updated = new Date(),
			configWasUpdated = false;

		if ((!oldConfigUpdated || oldConfigUpdated == 'Invalid Date') || (oldConfigUpdated < newConfigUpdated)) {
			CS.DB.config = config;
*/			var	localTables = config && config.tables ? config.tables : {};
	
			if (config && config.currency) {
				CS.App.currency = config.currency;
			}

			registerTables(localTables);

		return true;
	}

	function buildAllTables(progressApi) {
		Log.info('buildAllTables', CS.DB.tables);

		return buildTables(Object.keys(CS.DB.tables));

		function buildTables(keys) {
			var key = keys.shift();
			if (key) {
				return buildTable(key, CS.DB.tables[key], progressApi)
					.then(function() {
						return buildTables(keys);
					})
					.fail(function(e) {
						Log.error('Could not build all tables: ', e.message);
						throw e;
					});
			} else {
				return Q.resolve('All tables built');
			}
		}
	}

	function buildTable(tableName, table, progressApi) {
		Log.info('buildTable: ', tableName);

		if (!table) {
			return Q.reject('No table found with name ' + tableName);
		}

		if (progressApi) {
			progressApi.showProgress('Checking SFDC Metadata<br />' + (table.labelPlural || tableName));
		}

		if (table.sfdc) {
			if (navigator.connection && navigator.connection.type === Connection.NONE) {
				return Q('Device is offline');
			}

			return SFDC.getDescribe(tableName)
			.then(function(describe) {
				Log.info('About to create store ' + tableName);
				return LocalStore.createStoreForSfdcObject(tableName, table, describe);
			})
			.then(function() {
				return Q(tableName);
			})
			.fail(function(e) {
				return Q.reject(e);
			});
		} else {
			Log.info('Creating table ' + tableName);
			return LocalStore.createStore(tableName, table.indexSpec)
				.fail(function(e) {
					if (e === true) {
						// TODO - fix existing tables check
						return Q(tableName);
					} else {
						Log.info('Table could not be created: ' + tableName, e.message, e);
						return Q.reject(e);
					}
				});
		}

	}

	function checkDBSetup(progressApi) {
		Log.info('Checking DB setup...');
		if (progressApi) {
			progressApi.showProgress('Checking SFDC Metadata');
		}

		return LocalStore.getMetadataForAllStores()
				.then(function processStoreMetadata(results) {
					this._existingTables = {};
					Log.info('processStoreMetadata');

					for (var table in results) {
						this._existingTables[table] = true;
					}

					return DB.getConfig()
						.then(function(r) {
							Log.info('checkDBSetup config', r);
							return applyConfig(r);
						})
						.then(function() {
							return buildAllTables(progressApi);
						})
						.fail(function(e) {
							Log.info('BuildAllTables failed: ', e.message, e);
							return Q.reject(e);
						});
				}).fail(function(e) {
					Log.error(e);
					throw e;
				}).fin(function() {
					if (progressApi) {
						progressApi.hideProgress();
					}
				});
	}

	function getLocalConfig() {
		if (this.localConfig) {
			return Q.resolve(this.localConfig);
		} else {		
			return LocalStore.getLocalConfig()
				.then(function(config) {
					if (config) {
						Log.info('DefaultConfig present?', '' + (DB.defaultConfig != null));
						DB.config = _.extend(DB.defaultConfig || {}, config);
						return Q.resolve(DB.config);
					} else if (this.defaultConfig) {
						return Q.resolve(defaultConfig);
					} else {
						return Q.reject('No config found');
					}
				});
		}
	}

	function getRemoteConfig() {
		var d = Q.defer();

		getRemoteStaticResource(REMOTE_CONFIG_NAME, 'application/json', function processConfigBody(data) {
			var config;
			if (data) {
				try {
					config = JSON.parse(data);
					Log.info('>>> Got remote config: ', config);
				} catch (e) {
					Log.error('Could not parse static resource data: ', data);
				}
			}
			d.resolve(config);
		}, function(e) {
			Log.error('Could not get ' + REMOTE_CONFIG_NAME + ' static resource', e.message, e);
			var response;
			try {
				response = JSON.parse(e.responseText)[0];
			} catch (e2) {
				// no JSON responseText
				response = {message: e.status};
			}
			d.reject({
				message: 'Could not get ' + REMOTE_CONFIG_NAME + ' static resource: ' + response.message,
				xhr: e
			});
		});

		return d.promise;
	}

	function getRemoteStaticResource(name, contentType, success, error) {
		var nameParam = name ? name.replace(/'/g, "\\'") : "",
			contentTypeQuery = contentType ? " AND ContentType = '" + contentType.replace(/'/g, "\\'") + "'" : "",
			format = CONTENT_TYPES[contentType] ? CONTENT_TYPES[contentType] : TXT,
			query = "SELECT Id, Name, ContentType, Body, LastModifiedDate FROM StaticResource WHERE Name='" + nameParam + "'" + contentTypeQuery;

		Log.info('Looking for StaticResource', name);
		Log.info(SFDC);
		SFDC.query(
			query,
			function(result) {
				var record;
				Log.debug('Retrieved ', result.records.length, ' static resources for name ' + name + ', contentType ' + contentType + ', using first');
				if (result.records.length > 0) {
					record = result.records[0];
					record.Updated = new Date();
					getStaticResourceBody(record, format, success, error);
				} else {
					Log.info('No static resource found for name ' + name + ', contentType ' + contentType);
					success(undefined);
				}
			},
			error
		);
	
		function getStaticResourceBody(header, format, success, error) {
			SFDC.retrieveBinary(
				'StaticResource',
				header.Id + '/Body',
				function(xhr) {
					var uInt8Array = new Uint8Array(xhr.response),
						i = uInt8Array.length,
						binaryString = new Array(i),
						data,
						raw;

					while (i--) {
						binaryString[i] = String.fromCharCode(uInt8Array[i]);
					}
					raw = binaryString.join('');

					if (format === BIN) {
						data = window.btoa(raw);
					} else {
						data = raw;
					}

					LocalStore.storeStaticResource(header, data)
					.then(function() {
						Log.info('Stored StaticResource ', header);
						success(data);
					})
					.fail(function(e) {
						Log.error('Could not get StaticResource:', header, e.message, e);
						error(e);
					});
				}
			);
		}

	}

	function registerTables(localTables) {
		var	tables = CS.DB.tables = {};
		jQuery.extend(tables, standardTables);
		jQuery.extend(tables, localTables);
	}


	/**
		The primary API for accessing locally stored data on a device.

		@constructor
		@public
	*/
	function Database() {
		this.version = '1.0';
		this.config = {};
		this._LocalStore = LocalStore;
		this._standardTables = standardTables;
		this._existingTables = {};
	}

	/**
		Deletes records from the store matching the supplied ids

		@public
		@instance
		@function
	*/
	Database.prototype.delete = function _delete(store, ids) {
		return LocalStore.delete(store, ids);
	};

	/**
		Deletes records from the store matching the indexPath and value.

		@public
		@instance
		@function
	*/
	Database.prototype.remove = function remove(store, indexPath, value) {
		return LocalStore.remove(store, indexPath, value);
	};

	/**
	 	@public
		@instance
		@function
	 */
	Database.prototype.initOfflineDatabase = function initOfflineDatabase(version, defaultConfig) {
		var self = this;
		this.version = version || this.version;
		this.defaultConfig = defaultConfig;

		return LocalStore.init()
			.then(function() {
				return self.getConfig();
			});
	};

	/**
	 	@public
		@instance
	*/
	Database.prototype.formatDate = function formatDate(dt, withTime) {
		var day = dt.getDate(),
			month = dt.getMonth() + 1,
			year = dt.getYear() + 1900,
			hours = dt.getHours(),
			minutes = dt.getMinutes(),
			seconds = dt.getSeconds(),
			formattedDate = year + '-' + pad(month) + '-' + pad(day),
			formattedTime = pad(hours) + ':' + pad(minutes) + ':' + pad(seconds),
			formatted;

		if (withTime) {
			formatted = formattedDate + ' ' + formattedTime;
		} else {
			formatted = formattedDate;
		}

		return formatted;

		function pad(num) {
			return (num < 10) ? '0' + num : num;
		}

	};

	Database.prototype.findBy = function findBy(store, indexPath, value) {
		return LocalStore.findBy(store, indexPath, value);
	};

	/**
		Returns a promise to retrieve all records from the specified store name.
		The promise returns either a QueryResult (if pageSize is specified) pr
		an array of all records (if pageSize is not specified)

		@param 	store:String 			the name of the store
		@param 	[indexPath]:String		the path to sort on (default 'Id')
		@param 	[order]:String			'ASC' (default) or 'DESC'
		@param 	[pageSize]:Integer 		the size of cursor result pages (default 10)
	 	@public
		@instance
	*/
	Database.prototype.getAll = function getAll(store, indexPath, order, pageSize) {
		return LocalStore.getAll(store, indexPath, order, pageSize);
	};

	Database.prototype.getById = function getBy(store, id) {
		return LocalStore.getBy(store, 'Id', id);
/*			.then(function(queryResult) {
				var cursor = queryResult.getCursor();
				queryResult.closeCursor(cursor);
				if (cursor.currentPageOrderedEntries && cursor.currentPageOrderedEntries.length === 1) {
					return Q.resolve(cursor.currentPageOrderedEntries[0]);
				} else if (!cursor.currentPageOrderedEntries || !cursor.currentPageOrderedEntries.length) {
					return Q.reject('getById: No results for Soup: ' + soupName + ', indexPath: ' + indexPath + ', value: ' + value);
				} else if (cursor.currentPageOrderedEntries.length > 1) {
					return Q.reject('getById: Too many entries returned for Soup: ' + soupName + ', indexPath: ' + indexPath + ', value: ' + value);
				}
				return Q.reject('getById: unknown error');
			});
*/	};

	Database.prototype.getBy = function getBy(store, indexPath, value) {
		return LocalStore.getBy(store, indexPath, value);
	};

	Database.prototype.getConfig = function getConfig(localOnly) {
		if (localOnly || (navigator.connection && navigator.connection.type === window.Connection.NONE)) {
			return getLocalConfig();
		} else {
			return getRemoteConfig();
		}
	};

	Database.prototype.getFieldsForOfflineUpdate = function getSfdcFieldsForUpdate(table, includeId) {
		var fields = this.tables[table].allFields,
			list = [];

		for (var i = 0; i < fields.length; i++) {
			var field = fields[i];
			if (includeId || field !== 'Id') {
				list.push(field + ' = ?');
			}
		}

		return list.join(',');
	};

	Database.prototype.getLastSyncDate = function() {
		return LocalStore.getLastSyncDate();
	};

	Database.prototype.getSessionData = function() {
		return LocalStore.getSessionData();
	};

	/**
	 	@public
		@instance
	*/
	Database.prototype.getSfdcFieldsCsv = function getSfdcFieldsCsv(table) {
		return this.tables[table] && this.tables[table].sfdcFields ? this.tables[table].sfdcFields.join(',') : '';
	};

	/**
	 	@public
		@instance
	*/
	Database.prototype.getSfdcMetadata = function getSfdcMetadata(progressApi) {
		return getRemoteConfig()
			.fail(function(e) {
				// fail silently, error logged already
			})
			.fin(function() {
				Log.info('Proceeding to checkDBSetup...');
				return checkDBSetup(progressApi);
			});
	};

	// This should really move to SFDC lib
	Database.prototype.getAndStoreStaticResource = function getAndStoreStaticResource(name) {
		var d = Q.defer();

		getRemoteStaticResource(
			name,
			undefined,
			function success(data) {
				d.resolve(data);
			}, function error(e) {
				d.reject(e);
			}
		);

		return d.promise;
	};

	Database.prototype.getAllStaticResources = function getAllStaticResources() {
		return LocalStore.getAllStaticResources();
	};

	Database.prototype.parseDate = function parseDate(d) {
		var str = '' + d,
			trimmed = str.substring(0, str.indexOf('+'));
		return new Date(trimmed);
	};

	Database.prototype.resetDatabase = function resetDatabase() {
		return LocalStore.getMetadataForAllStores()
			.then(function(tables) {
				return removeTables(Object.keys(tables));
			})
			.then(LocalStore.removeMetadata)
			.then(LocalStore.init)
			.fail(function(e) {
				Log.error('Could not reset database: ', e.message, e);
				throw e;
			});
		
		function removeTables(tables) {
			var table = tables.shift();
			if (table) {
				return LocalStore.removeStore(table)
				.then(function() {
					return removeTables(tables);
				}).fail(function(e) {
					Log.error(e.message);
					Log.error(e);
					throw e;
				});
			} else {
				Log.info('Removed all tables');
				return Q.resolve();
			}
		}
	};

	Database.prototype.resetProductCatalogue = function resetProductCatalogue(db) {
		throw 'resetProductCatalogue implementation requied for SmartStore';
	};

	Database.prototype.setLastSyncDate = function(date) {
		return LocalStore.setLastSyncDate(date);
	};

	Database.prototype.setSessionData = function setSessionData(sessionData) {
		return LocalStore.setSessionData(sessionData);
	};

	/**
		Returns a promise to perform the specified SmartSQL query against a SmartStore.
		The promise returns a QueryResult. SmartQueries have a quirky return style, as follows:

		Each object is returns wrapped in an array. So the returned results will be
		an array of arrays. The outer array is the list of results and each inner array
		corresponds to a single result.

		For simple queries, each inner array will contain a single entry - the selected object.
		
		For joined queries, the inner arrays will contain as many entries as tables were joined.
		Somewhat bizarrely, the first entry, the object from the primary table of the query,
		will be represented as a JavaScript object; whereas the objects form the other joined
		tables will be returned as JSON strings. You can JSON.parse() these to get the actual
		objects. My guess is that this to avoid performance issues with larger queries.

		@param 	query:String 			the query to execute
		@param 	[pageSize]:Integer 		the number of records per page to return (defult 10)
		@public
		@instance
	*/
	Database.prototype.smartQuery = function(query, pageSize) {
		return LocalStore.smartQuery(query, pageSize);
	};

	Database.prototype.sortResults = function(promise, sortKey, order) {
		return promise.then(function(results) {
			var xs = _.sortBy(results, sortKey);
			return (order == 'DESC') ? xs.reverse() : xs;
		});
	};

	Database.prototype.sql = function sql(db, command, func) {
		// Convenience - optional parameters
		if (db.statement) {
			command = db;
		} else {
			if (typeof command === 'function') {
				func = command;
			}
			if (typeof db === 'string') {
				command = {statement: db};
			}
		}
		try {
			Log.error('********** SQL is deprecated ************************************');
			Log.error(command);
			throw new Error('>>> SQL is deprecated <<<');
		} catch (sqle) {
			Log.error(sqle.message);
			Log.error(sqle);
		}
	};

	Database.prototype.storeExists = function storeExists(store) {
		return LocalStore.storeExists(store);
	};

	/**
		Returns a promise to update all the records in the map 'keys' with the key/value pairs in the map 'values'.
		Keys map should consist of a single entry with a single value or array of values. Typically this will be
		using Id, e.g. {Id: ['1', '2']} or {Id: '1'}
		Values map should consist of key/value pairs for each field to update on the target records.
		Records in keys not found in the database are ignored.

		@param 	store:String 		the store to update
		@param 	keys:Object 		the keys for records in the store to update
		@param 	values:Object		the values to apply to the records
		@public
		@instance
	 */
	Database.prototype.updateAll = function update(store, keys, values) {
		var keyName,
			keyValue,
			predicate,
			isArray,
			self = this;

		// expect one. If multiple, the last will be used.
		for (var key in keys) {
			keyName = key;
			var val = keys[keyName];
			isArray = Array.isArray(val);
			keyValue = isArray ? val.join('\',\'') : val; // assume strings/IDs for now
			predicate = isArray ? 'IN (\'' + keyValue + '\')' : '\'' + keyValue + '\'';
		}

		return LocalStore.smartQuery('SELECT {' + store + ':_soup} FROM {' + store + '} WHERE {' + store + ':' + keyName + '} ' + predicate, 1000)
			.then(function(records) {
				_.each(records, function(record) {
					_.each(Object.keys(values), function(key) {
						record[key] = values[key];
					});
				});
				return records;
			})
			.then(function(records) {
				return self.upsert(store, records, keyName);
			})
			.fail(function(e) {
				Log.error('Could not updateAll: ', e.message);
				throw e;
			});

	};

	/**
		Returns a promise to perform an upsert of the supplied records in the store,
		identified by the externalIdKey.

		@param 	store:String 			the name of the store
		@param 	records:Array 			the records to upsert
		@param 	externalIdKey:String 	the key path on which to identify records (for insertion/updating)
	*/
	Database.prototype.upsert = function upsert(store, records, externalIdKey) {
		Log.info('Upsert', store, externalIdKey);
		return LocalStore.upsert(store, records, externalIdKey);
	};

	/** Private elements exposed for testing convenience **/
	Database.prototype._buildAllTables = buildAllTables;

	Database.prototype._buildTable = buildTable;

	Database.prototype._checkDBSetup = checkDBSetup;

	Database.prototype._getLocalConfig = getLocalConfig;

	Database.prototype._getRemoteConfig = getRemoteConfig;


	var Log = CS.Log,
		DB = CS.DB = new Database();

	return DB;

});
define('src/csapp',[
	'./csbase',
	'./cs-database',
	'./cs-sfdc',
	'./csutil',
	'node_modules/q/q'
], function(CS, DB, SFDC, Util, Q) {
	var App = {
		changeScreen: changeScreen,
		currency: {
			code: 'GBP',
			htmlSymbol: '&pound;'
		},
		getController: getController,
		init: init,
		loadJson: loadJson,
		loadScreen: loadScreen,
		getOrgId: getOrgId,
		getLastOrgId: getLastOrgId,
		hasOrgIdChanged: hasOrgIdChanged,
		processStaticResources: processStaticResources,
		refreshScreen: refreshScreen,
		progress: {
			showProgress: function(progress, message) {
				showProgress(progress, message);
			},
			hideProgress: function() {
				hideProgress();
			}
		},
		showProgress: showProgress,
		hideProgress: hideProgress
	},
	application,
	jsonCache = {},
	jsContentTypes = ['text/javascript', 'application/javascript', 'application/x-javascript'],
	loadedScreens = {},
	Log = CS.Log,
	nextBindingId = 1,
	nextFunctionId = 1,
	overlay = '<div class="CS-overlay" style="position: absolute; top: 0; left: 0; bottom: 0; right: 0"></div>',
	screens = {},
	stackDepth = 0,
	staticResourcesHaveBeenProcessed = false;

	return App;

	function buildController(c, name) {
		Log.debug('Building controller with delegate:', name);

		var controller = {
			activate: activate,
			changeScreen: changeScreen,
			delegate: c,
			initialised: false,
			registerAction: registerAction,
			screenHasChanged: screenHasChanged,
			screenWillChange: screenWillChange,
			wiringQueued: false
		};

		if (c) {
			c.app = application;
			if (c.screens) {
				for (var screen in c.screens) {
					screens[name + '.' + screen] = c.screens[screen];
				}
			}
			c.changeScreen = changeScreen;
			c.pushScreen = pushScreen;
			c.popScreen = popScreen;
			c.refreshScreen = refreshScreen;
			if (!c.state) {
				c.state = {};
			}
			c.wireActions = function() {
				wireActions(c);
			};
		}

		return controller;

		function actionIsBoundToElement(action, el) {
			var bindingId = el.getAttribute('data-cs-binding-id');

			if (bindingId === null) {
				bindingId = nextBindingId++;
				el.setAttribute('data-cs-binding-id', bindingId);
			}

			if (!action.bindingIds) {
				action.bindingIds = {};
			}

			return action.bindingIds[bindingId] !== undefined;
		}

		function activate() {
			if (this.delegate && this.delegate.activate) {
				this.delegate.activate.apply(this.delegate, arguments);
			}
			wireActions(this.delegate);
		}

		function changeScreen(screenName, context) {
			c.state.context = context;
			CS.App.changeScreen(name, screenName, context);
			c.state.currentScreen = screenName;
			wireActions(c);
		}

		function popScreen() {
			application.navigation.popScreen();
		}

		function pushScreen(screenName, context, sections) {
			var spec = application.main.delegate.getNewScreenSpec(screenName, context, sections);
			application.navigation.pushScreen(spec.selector, spec.fragment);
			refreshScreen(screenName, context, sections);
		}

		function refreshScreen(screenName, context, sections) {
			c.state.context = context;
			CS.App.refreshScreen(name + '.' + screenName, context, sections);
			wireActions(c);
		}

		function registerAction(name, action, override) {
			if (this.actions[name] && !override) {
				Log.error('Action with name ' + name + ' already exists, ignoring');
				return;
			}

			this.actions[name] = action;
			if (this.initialised && !this.wiringQueued) {
				wireActions(this);
			}
		}

		function screenHasChanged(controllerName, screenName) {
			if (controller.delegate && controller.delegate.screenHasChanged) {
				controller.delegate.screenHasChanged(controllerName, screenName);
			}
		}

		function screenWillChange(controllerName, screenName) {
			if (controller.delegate && controller.delegate.screenWillChanged) {
				controller.delegate.screenWillChange(controllerName, screenName);
			}
		}

		function wireAction(actionName, action, eventName, cssOverride) {
			var e = (eventName || 'click') + '.CS',
				css = cssOverride || {cursor: 'pointer'},
				func = wrapEventFunction(action, actionName);

			if (Log.isDebugEnabled()) {
				Log.debug('Wiring action:', actionName);
			}
			jQuery('[data-cs-action="' + actionName + '"]').each(function (i, it) {
				if (!actionIsBoundToElement(action, it)) {
					action.bindingIds[it.getAttribute('data-cs-binding-id')] = true;
					var ev = it.getAttribute('data-cs-event');
					e = ev ? ev + '.CS' : e;
					jQuery(it).on(e, func).css(css);
				}
			});
			jQuery('[data-cs-form-action="' + actionName + '"]').on('submit.CS', func);
		}

		function wireActions(c) {
			Log.debug('wireActions', c.name, c);
			for (var actionName in c.actions) {
				wireAction(actionName, c.actions[actionName]);
			}
			if (c.name != 'main') {
				application.main.delegate.wireActions();
			}
		}

		function wrapEventFunction(f, name) {
			return _.debounce(function(e) {
				Log.debug(name);
				var el = jQuery(event.currentTarget),
					group = el.attr('data-cs-group'),
					json = el.attr('data-cs-params'),
					params = json ? JSON.parse(json) || {} : {};

				params.el = el;
				params.group = group;

				el.addClass('clicked').attr('disabled', 'disabled');

				try {
					f(application, e, params);
				} catch (err) {
					Log.error(err.message, err);
				} finally {
					el.removeClass('clicked').removeAttr('disabled');
				}


				return false;
			}, 300, true);
		}
	}

	function hasOrgIdChanged() {
		Log.info('hasOrgIdChanged()');
		return getLastOrgId()
			.then(function(id) {
				return SFDC.hasOrgIdChanged(id);
			});
	}

	function getOrgId() {
		var sessionData = SFDC.getSessionData();
		return sessionData ? sessionData.orgId : undefined;
	}

	function getLastOrgId() {
		return DB.getSessionData()
			.then(function(data) {
				var id = (data && data.orgId ? data.orgId : undefined);
				return id;
			})
			.fail(function(e) {
				Log.error(e.message);
				Log.error(e);
				throw e;
			});
	}

	function buildNavigation(delegate) {
		var nav = (delegate && delegate.navigation) ? delegate.navigation : {};

		return {
			getStackDepth: function getStackDepth() { return stackDepth; },
			select: nav.select || selectNav,
			popScreen: nav.popScreen || popScreen,
			pushScreen: nav.pushScreen || pushScreen
		};

		function selectNav(actionName) {
			var responders = jQuery('[data-cs-action="' + actionName + '"]');
			responders.parents('aside').find('[data-cs-action]').removeClass('selected');
			responders.addClass('selected');
		}

		function pushScreen(selector, htmlText) {
			jQuery('[data-cs-depth="' + (stackDepth-1) + '"]').removeClass('depth0').addClass('depth-1');
			jQuery('[data-cs-depth="' + stackDepth + '"]').removeClass('depth1').addClass('depth0');
			var overlayElement = jQuery(overlay).on('click.CS', popScreen);
			jQuery('[data-cs-root="' + stackDepth + '"]').append(overlayElement);
			var html = jQuery(htmlText).attr('data-cs-root', ++stackDepth);
			html.filter('[data-cs-displays]').attr('data-cs-depth', stackDepth).addClass('depth2');
			jQuery(selector).append(html);
			setTimeout(function() { jQuery('[data-cs-depth="' + stackDepth + '"]').removeClass('depth2').addClass('depth1'); }, 100);
		}

		function popScreen() {
			if (stackDepth > 0) {
				jQuery('[data-cs-depth="' + stackDepth + '"]').removeClass('depth1').addClass('depth2');
				if (stackDepth > 1) {
					jQuery('[data-cs-depth="' + (stackDepth-1) + '"]').removeClass('depth0').addClass('depth1');
					jQuery('[data-cs-depth="' + (stackDepth-2) + '"]').removeClass('depth-1').addClass('depth0');
				}
				var selector = '[data-cs-root="' + stackDepth + '"]';
				setTimeout(function() { jQuery(selector).remove(); }, 400);
				stackDepth -= 1;
				jQuery('[data-cs-root="' + stackDepth + '"]').find('.CS-overlay').remove();
			}
		}
	}

	function changeScreen(prefix, name, context, sectionFilter) {
		var	fullName = prefix + '.' + name;

		for (var i in application.controllers) {
			application.controllers[i].screenWillChange(prefix, name);
		}

		refreshScreen(fullName, context, sectionFilter);

		for (i in application.controllers) {
			application.controllers[i].screenHasChanged(prefix, name);
		}

	}

	function getController(name) {
		var controller = application.controllers[name];

		if (!controller) {
			Log.error('Could not find controller with name ' + name);
		}

		return controller;
	}

	function init(appDelegate) {
		if (application) {
			CS.Log.error('Init called on initialised application');
			return;
		}

		Log.info('Initialising app with delegate:', appDelegate.name);

		var controllers = {};

		App.application = application = {
			changeScreen: changeScreen,
			controllers: controllers,
			delegate: appDelegate,
			navigation: buildNavigation(appDelegate)
		};

		if (appDelegate.controllers) {
			for (var controllerName in appDelegate.controllers) {
				var controllerDelegate = appDelegate.controllers[controllerName],
					controller = buildController(controllerDelegate, controllerName);
				controllers[controllerName] = controller;
				if (controllerName === 'main') {
					application.main = controller;
				}
			}
		}

		if (controllers.main) {
			controllers.main.activate();
		}
	}

	function loadJson(url, success, error) {
		var json = jsonCache[url];
		if (!json) {
			jQuery.ajax({
				async: false,
				dataType: 'text',
				error: function(x, e, d) {
					Log.error('Error loading JSON ' + url, x, e, d);
					if (error) {
						error(x, e, d);
					}
				},
				global: false,
				success: function(data) {
					Log.debug('Loaded JSON ' + url);
					json = JSON.parse(data);
					if (success) {
						success(json);
					}
				},
				url: url
			});
		}
		return json;
	}

	function loadScreen(name, url, processor) {
		if (typeof url === 'function') {
			processor = url;
			url = name;
		}
		if (!url) {
			url = name;
		}
		if (loadedScreens[name]) {
			Log.debug('Screen ' + name + ' already loaded');
			return;
		}
		var screenHTML;
		jQuery.ajax({
			async: false,
			dataType: 'html',
			global: false,
			url: url
		}).done(function(data) {
			Log.debug('Loaded screen ' + name);
			screenHTML = data;
		}).fail(function(a,b,c) {
			Log.error('Ajax error:', a, b, c);
		});
		try {
			if (screenHTML) {
				screenHTML = screenHTML.replace(/\{\{screenName\}\}/ig, name);
			}
			var toAppend = typeof processor === 'function' ? processor(screenHTML) : screenHTML;
			jQuery('body').append(toAppend);
			loadedScreens[name] = true;
		} catch (e) {
			Log.error(e);
		}
	}

	function refreshScreen(fullName, ctx, sectionFilter, callback) {
		var	context = ctx || {},
			html,
			sections = {},
			screen = screens[fullName],
			templates;

		if (!screen) {
			Log.error('Screen ', fullName ,'not defined');
			return;
		}

		if (screen.view && !loadedScreens[fullName]) {
			loadScreen(fullName, screen.view);
		}

		context.app = application;
		context.currencySymbol = App.currency && App.currency.htmlSymbol ? App.currency.htmlSymbol: '';

		Log.info('Building screen:', fullName, sectionFilter ? sectionFilter : ', all sections');
		templates = jQuery('script[data-cs-screen="' + fullName + '"]').sort(function(a, b) {
			var x = parseInt(jQuery(a).attr('data-cs-order'), 10) || 0,
				y = parseInt(jQuery(b).attr('data-cs-order'), 10) || 0;
			return (x < y) ? -1 : (x > y) ? 1 : 0;
		});
		templates.each(function(i, it){
			var section = it.getAttribute('data-cs-section'),
				sectionMatch = (!sectionFilter || sectionFilter.indexOf(section) > -1),
				type = it.getAttribute('data-cs-type'),
				typeMatch = !type || context[section] && context[section].type && type == context[section].type;

			if (section && sectionMatch && typeMatch) {
				Log.debug('Adding content for section', section, (type ? 'type ' + type : ''));
				sections[section] = it.innerHTML;
			}
		});
		populateContent(sections, context);
		jQuery('div.scrollable').on('touchmove.CS', function(e) {
			e.stopPropagation();
			return true;
		});

		if (typeof callback === 'function') {
			callback(context);
		}

		function populateContent(sections, context) {
			var	content,
				html,
				name;
			for (name in sections) {
				content = sections[name];
				if (content) {
					try {
						html = CS.Util.template(content, context || {});
					} catch (e) {
						Log.error('Could not populate content for ' + name + ': ' + e.message, e);
					}
					Log.debug('Populating content for', name, 'depth', stackDepth);
					var el = jQuery('[data-cs-displays="' + name + '"][data-cs-depth="' + stackDepth + '"], [data-cs-displays="' + name + '"]:not([data-cs-depth])');
					el.html(html);
					Log.debug('HTML has content', ''+!html.match(/\s+/), html);
					if (!html.match(/^\s+$/mg)) {
						el.removeClass('hidden');
					} else {
						el.addClass('hidden');
					}
				} else {
					Log.info('No content for ' + name);
				}
			}
		}
	}

	function processStaticResources(override) {
		if (staticResourcesHaveBeenProcessed && !override) {
			return Q.resolve();
		}
		
		// create static resource directory structure:
		// -- staticresources
		//		+- css
		//		+- js
		//		+- zip
		//
		// Unpack each static resource into the appropriate folder

		return DB.getAllStaticResources()
			.then(function(resources) {
				showProgress('Processing<br />Resources');
				_.each(resources, function(it) {
					if (jsContentTypes.indexOf(it.ContentType) > -1) {
						try {
							Log.info('Processing resource', it.Name);
							window.eval.call(window, it.Data);
							Log.info('Processed resource', it.Name);
						} catch (e) {
							Log.error('Could not eval static resource ' + it.Name, e.message, e);
						}
					} else {
						Log.info('Static resource', it.Name, 'not processed - unsupported contentType:', it.ContentType);
					}
				});
			})
			.fail(function(e) {
				Log.error('Error processing static resources', e.message, e);
			})
			.fin(hideProgress);
	}

	function showProgress(progress, message) {
		if (!message) {
			message = progress;
		}
		if (jQuery.mobile) {
			if (message !== undefined) {
				jQuery.mobile.loading('show', {
					html: '<span class="ui-icon ui-icon-loading"></span><h1>' + message + '</h1>',
					textVisible: true,
					theme: 'a'
				});
			} else {
				jQuery.mobile.loading('show', {theme: 'a'});
			}
		}
	}

	function hideProgress() {
		if (jQuery.mobile) {
			jQuery.mobile.loading('hide');
		}

	}

});


/* big.js v2.2.0 https://github.com/MikeMcl/big.js/LICENCE */
;(function ( global ) {
    

    /*
      big.js v2.2.0
      A small, fast, easy-to-use library for arbitrary-precision decimal arithmetic.
      https://github.com/MikeMcl/big.js/
      Copyright (c) 2012 Michael Mclaughlin <M8ch88l@gmail.com>
      MIT Expat Licence
    */

    /****************************** EDITABLE DEFAULTS **********************************/


    // The default values below must be integers within the stated ranges (inclusive).

    /*
     * The maximum number of decimal places of the results of methods involving
     * division, i.e. 'div' and 'sqrt', and 'pow' with negative exponents.
     */
    Big['DP'] = 20;                                  // 0 to MAX_DP

    /*
     * The rounding mode used when rounding to the above decimal places.
     *
     * 0 Round towards zero (i.e. truncate, no rounding).               (ROUND_DOWN)
     * 1 Round to nearest neighbour. If equidistant, round up.          (ROUND_HALF_UP)
     * 2 Round to nearest neighbour. If equidistant, to even neighbour. (ROUND_HALF_EVEN)
     * 3 Round away from zero.                                          (ROUND_UP)
     */
    Big['RM'] = 1;                                   // 0, 1, 2 or 3

        // The maximum value of 'Big.DP'.
    var MAX_DP = 1E6,                                // 0 to 1e+6

        // The maximum magnitude of the exponent argument to the 'pow' method.
        MAX_POWER = 1E6,                             // 1 to 1e+6

        /*
         * The exponent value at and beneath which 'toString' returns exponential notation.
         * Javascript's Number type: -7
         * -1e+6 is the minimum recommended exponent value of a Big.
         */
        TO_EXP_NEG = -7,                             // 0 to -1e+6

        /*
         * The exponent value at and above which 'toString' returns exponential notation.
         * Javascript's Number type: 21
         * 1e+6 is the maximum recommended exponent value of a Big, though there is no
         * enforcing or checking of a limit.
         */
        TO_EXP_POS = 21,                             // 0 to 1e+6


    /***********************************************************************************/

        P = Big.prototype,
        isValid = /^-?(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$/i,
        ONE = new Big(1);


    // CONSTRUCTOR


    /*
     * The exported function.
     * Create and return a new instance of a Big object.
     *
     * n {number|string|Big} A numeric value.
     */
    function Big( n ) {
        var i, j, nL,
            x = this;

        // Enable constructor usage without new.
        if ( !(x instanceof Big) ) {
            return new Big( n )
        }

        // Duplicate.
        if ( n instanceof Big ) {
            x['s'] = n['s'];
            x['e'] = n['e'];
            x['c'] = n['c'].slice();
            return
        }

        // Minus zero?
        if ( n === 0 && 1 / n < 0 ) {
            n = '-0'
        // Ensure 'n' is string and check validity.
        } else if ( !isValid.test(n += '') ) {
            throw NaN
        }

        // Determine sign.
        x['s'] = n.charAt(0) == '-' ? ( n = n.slice(1), -1 ) : 1;

        // Decimal point?
        if ( ( i = n.indexOf('.') ) > -1 ) {
            n = n.replace( '.', '' )
        }

        // Exponential form?
        if ( ( j = n.search(/e/i) ) > 0 ) {

            // Determine exponent.
            if ( i < 0 ) {
                i = j
            }
            i += +n.slice( j + 1 );
            n = n.substring( 0, j )

        } else if ( i < 0 ) {

            // Integer.
            i = n.length
        }

        // Determine leading zeros.
        for ( j = 0; n.charAt(j) == '0'; j++ ) {
        }

        if ( j == ( nL = n.length ) ) {

            // Zero.
            x['c'] = [ x['e'] = 0 ]
        } else {

            // Determine trailing zeros.
            for ( ; n.charAt(--nL) == '0'; ) {
            }

            x['e'] = i - j - 1;
            x['c'] = [];

            // Convert string to array of digits (without leading and trailing zeros).
            for ( i = 0; j <= nL; x['c'][i++] = +n.charAt(j++) ) {
            }
        }
    }


    // PRIVATE FUNCTIONS


    /*
     * Round Big 'x' to a maximum of 'dp' decimal places using rounding mode
     * 'rm'. (Called by 'div', 'sqrt' and 'round'.)
     *
     * x {Big} The Big to round.
     * dp {number} Integer, 0 to MAX_DP inclusive.
     * rm {number} 0, 1, 2 or 3 ( ROUND_DOWN, ROUND_HALF_UP, ROUND_HALF_EVEN, ROUND_UP )
     * [more] {boolean} Whether the result of division was truncated.
     */
    function rnd( x, dp, rm, more ) {
        var xc = x['c'],
            i = x['e'] + dp + 1;

        if ( rm === 1 ) {
            // 'xc[i]' is the digit after the digit that may be rounded up.
            more = xc[i] >= 5
        } else if ( rm === 2 ) {
            more = xc[i] > 5 || xc[i] == 5 && ( more || i < 0 || xc[i + 1] != null || xc[i - 1] & 1 )
        } else if ( rm === 3 ) {
            more = more || xc[i] != null || i < 0
        } else if ( more = false, rm !== 0 ) {
            throw '!Big.RM!'
        }

        if ( i < 1 || !xc[0] ) {
            x['c'] = more
              // 1, 0.1, 0.01, 0.001, 0.0001 etc.
              ? ( x['e'] = -dp, [1] )
              // Zero.
              : [ x['e'] = 0 ];
        } else {

            // Remove any digits after the required decimal places.
            xc.length = i--;

            // Round up?
            if ( more ) {

                // Rounding up may mean the previous digit has to be rounded up and so on.
                for ( ; ++xc[i] > 9; ) {
                    xc[i] = 0;

                    if ( !i-- ) {
                        ++x['e'];
                        xc.unshift(1)
                    }
                }
            }

            // Remove trailing zeros.
            for ( i = xc.length; !xc[--i]; xc.pop() ) {
            }
        }

        return x
    }


    /*
     * Return
     * 1 if the value of Big 'x' is greater than the value of Big 'y',
     * -1 if the value of Big 'x' is less than the value of Big 'y', or
     * 0 if they have the same value,
     */
    function cmp( x, y ) {
        var xNeg,
            xc = x['c'],
            yc = ( y = new Big( y ) )['c'],
            i = x['s'],
            j = y['s'],
            k = x['e'],
            l = y['e'];

        // Either zero?
        if ( !xc[0] || !yc[0] ) {
            return !xc[0] ? !yc[0] ? 0 : -j : i
        }

        // Signs differ?
        if ( i != j ) {
            return i
        }
        xNeg = i < 0;

        // Compare exponents.
        if ( k != l ) {
            return k > l ^ xNeg ? 1 : -1
        }

        // Compare digit by digit.
        for ( i = -1,
              j = ( k = xc.length ) < ( l = yc.length ) ? k : l;
              ++i < j; ) {

            if ( xc[i] != yc[i] ) {
                return xc[i] > yc[i] ^ xNeg ? 1 : -1
            }
        }

        // Compare lengths.
        return k == l ? 0 : k > l ^ xNeg ? 1 : -1
    };


    // PROTOTYPE/INSTANCE METHODS


    /*
     * Return a new Big whose value is the absolute value of this Big.
     */
    P['abs'] = function () {
        var x = new Big(this);
        x['s'] = 1;

        return x
    };


    /*
     * Return a new Big whose value is the value of this Big divided by the
     * value of Big 'y', rounded, if necessary, to a maximum of 'Big.DP'
     * decimal places using rounding mode 'Big.RM'.
     */
    P['div'] = function ( y ) {
        var x = this,
            dvd = x['c'],
            dvs = ( y = new Big(y) )['c'],
            s = x['s'] == y['s'] ? 1 : -1,
            dp = Big['DP'];

        if ( dp !== ~~dp || dp < 0 || dp > MAX_DP ) {
            throw '!Big.DP!'
        }

        // Either 0?
        if ( !dvd[0] || !dvs[0] ) {

            // Both 0?
            if ( dvd[0] == dvs[0] ) {
                throw NaN
            }

            // 'dvs' is 0?
            if ( !dvs[0] ) {
                // Throw +-Infinity.
                throw s / 0
            }

            // 'dvd' is 0. Return +-0.
            return new Big( s * 0 )
        }


        var dvsL, dvsT, next, cmp, remI,
            dvsZ = dvs.slice(),
            dvdI = dvsL = dvs.length,
            dvdL = dvd.length,
            rem = dvd.slice( 0, dvsL ),
            remL = rem.length,
            quo = new Big(ONE),
            qc = quo['c'] = [],
            qi = 0,
            digits = dp + ( quo['e'] = x['e'] - y['e'] ) + 1;

        quo['s'] = s;
        s = digits < 0 ? 0 : digits;

        // Create version of divisor with leading zero.
        dvsZ.unshift(0);

        // Add zeros to make remainder as long as divisor.
        for ( ; remL++ < dvsL; rem.push(0) ) {
        }

        do {

            // 'next' is how many times the divisor goes into the current remainder.
            for ( next = 0; next < 10; next++ ) {

                // Compare divisor and remainder.
                if ( dvsL != ( remL = rem.length ) ) {
                    cmp = dvsL > remL ? 1 : -1
                } else {
                    for ( remI = -1, cmp = 0; ++remI < dvsL; ) {

                        if ( dvs[remI] != rem[remI] ) {
                            cmp = dvs[remI] > rem[remI] ? 1 : -1;
                            break
                        }
                    }
                }

                // Subtract divisor from remainder (if divisor < remainder).
                if ( cmp < 0 ) {

                    // Remainder cannot be more than one digit longer than divisor.
                    // Equalise lengths using divisor with extra leading zero?
                    for ( dvsT = remL == dvsL ? dvs : dvsZ; remL; ) {

                        if ( rem[--remL] < dvsT[remL] ) {

                            for ( remI = remL;
                                  remI && !rem[--remI];
                                  rem[remI] = 9 ) {
                            }
                            --rem[remI];
                            rem[remL] += 10
                        }
                        rem[remL] -= dvsT[remL]
                    }
                    for ( ; !rem[0]; rem.shift() ) {
                    }
                } else {
                    break
                }
            }

            // Add the 'next' digit to the result array.
            qc[qi++] = cmp ? next : ++next;

            // Update the remainder.
            rem[0] && cmp
              ? ( rem[remL] = dvd[dvdI] || 0 )
              : ( rem = [ dvd[dvdI] ] )

        } while ( ( dvdI++ < dvdL || rem[0] != null ) && s-- );

        // Leading zero? Do not remove if result is simply zero (qi == 1).
        if ( !qc[0] && qi != 1) {

            // There can't be more than one zero.
            qc.shift();
            quo['e']--;
        }

        // Round?
        if ( qi > digits ) {
            rnd( quo, dp, Big['RM'], rem[0] != null )
        }

        return quo
    }


    /*
     * Return true if the value of this Big is equal to the value of Big 'y',
     * otherwise returns false.
     */
    P['eq'] = function ( y ) {
        return !cmp( this, y )
    };


    /*
     * Return true if the value of this Big is greater than the value of Big 'y',
     * otherwise returns false.
     */
    P['gt'] = function ( y ) {
        return cmp( this, y ) > 0
    };


    /*
     * Return true if the value of this Big is greater than or equal to the
     * value of Big 'y', otherwise returns false.
     */
    P['gte'] = function ( y ) {
        return cmp( this, y ) > -1
    };


    /*
     * Return true if the value of this Big is less than the value of Big 'y',
     * otherwise returns false.
     */
    P['lt'] = function ( y ) {
        return cmp( this, y ) < 0
    };


    /*
     * Return true if the value of this Big is less than or equal to the value
     * of Big 'y', otherwise returns false.
     */
    P['lte'] = function ( y ) {
         return cmp( this, y ) < 1
    };


    /*
     * Return a new Big whose value is the value of this Big minus the value
     * of Big 'y'.
     */
    P['minus'] = function ( y ) {
        var d, i, j, xLTy,
            x = this,
            a = x['s'],
            b = ( y = new Big( y ) )['s'];

        // Signs differ?
        if ( a != b ) {
            return y['s'] = -b, x['plus'](y)
        }

        var xc = x['c'].slice(),
            xe = x['e'],
            yc = y['c'],
            ye = y['e'];

        // Either zero?
        if ( !xc[0] || !yc[0] ) {

            // 'y' is non-zero?
            return yc[0]
              ? ( y['s'] = -b, y )
              // 'x' is non-zero?
              : new Big( xc[0]
                ? x
                // Both are zero.
                : 0 )
        }

        // Determine which is the bigger number.
        // Prepend zeros to equalise exponents.
        if ( a = xe - ye ) {
            d = ( xLTy = a < 0 ) ? ( a = -a, xc ) : ( ye = xe, yc );

            for ( d.reverse(), b = a; b--; d.push(0) ) {
            }
            d.reverse()
        } else {

            // Exponents equal. Check digit by digit.
            j = ( ( xLTy = xc.length < yc.length ) ? xc : yc ).length;

            for ( a = b = 0; b < j; b++ ) {

                if ( xc[b] != yc[b] ) {
                    xLTy = xc[b] < yc[b];
                    break
                }
            }
        }

        // 'x' < 'y'? Point 'xc' to the array of the bigger number.
        if ( xLTy ) {
            d = xc, xc = yc, yc = d;
            y['s'] = -y['s']
        }

        /*
         * Append zeros to 'xc' if shorter. No need to add zeros to 'yc' if shorter
         * as subtraction only needs to start at 'yc.length'.
         */
        if ( ( b = -( ( j = xc.length ) - yc.length ) ) > 0 ) {

            for ( ; b--; xc[j++] = 0 ) {
            }
        }

        // Subtract 'yc' from 'xc'.
        for ( b = yc.length; b > a; ){

            if ( xc[--b] < yc[b] ) {

                for ( i = b; i && !xc[--i]; xc[i] = 9 ) {
                }
                --xc[i];
                xc[b] += 10
            }
            xc[b] -= yc[b]
        }

        // Remove trailing zeros.
        for ( ; xc[--j] == 0; xc.pop() ) {
        }

        // Remove leading zeros and adjust exponent accordingly.
        for ( ; xc[0] == 0; xc.shift(), --ye ) {
        }

        if ( !xc[0] ) {

            // Result must be zero.
            xc = [ye = 0]
        }

        return y['c'] = xc, y['e'] = ye, y
    };


    /*
     * Return a new Big whose value is the value of this Big modulo the
     * value of Big 'y'.
     */
    P['mod'] = function ( y ) {
        y = new Big( y );
        var c,
            x = this,
            i = x['s'],
            j = y['s'];

        if ( !y['c'][0] ) {
            throw NaN
        }

        x['s'] = y['s'] = 1;
        c = cmp( y, x ) == 1;
        x['s'] = i, y['s'] = j;

        return c
          ? new Big(x)
          : ( i = Big['DP'], j = Big['RM'],
            Big['DP'] = Big['RM'] = 0,
              x = x['div'](y),
                Big['DP'] = i, Big['RM'] = j,
                  this['minus']( x['times'](y) ) )
    };


    /*
     * Return a new Big whose value is the value of this Big plus the value
     * of Big 'y'.
     */
    P['plus'] = function ( y ) {
        var d,
            x = this,
            a = x['s'],
            b = ( y = new Big( y ) )['s'];

        // Signs differ?
        if ( a != b ) {
            return y['s'] = -b, x['minus'](y)
        }

        var xe = x['e'],
            xc = x['c'],
            ye = y['e'],
            yc = y['c'];

        // Either zero?
        if ( !xc[0] || !yc[0] ) {

            // 'y' is non-zero?
            return yc[0]
              ? y
              : new Big( xc[0]

                // 'x' is non-zero?
                ? x

                // Both are zero. Return zero.
                : a * 0 )
        }

        // Prepend zeros to equalise exponents.
        // Note: Faster to use reverse then do unshifts.
        if ( xc = xc.slice(), a = xe - ye ) {
            d = a > 0 ? ( ye = xe, yc ) : ( a = -a, xc );

            for ( d.reverse(); a--; d.push(0) ) {
            }
            d.reverse()
        }

        // Point 'xc' to the longer array.
        if ( xc.length - yc.length < 0 ) {
            d = yc, yc = xc, xc = d
        }

        /*
         * Only start adding at 'yc.length - 1' as the
         * further digits of 'xc' can be left as they are.
         */
        for ( a = yc.length, b = 0; a;
             b = ( xc[--a] = xc[a] + yc[a] + b ) / 10 ^ 0, xc[a] %= 10 ) {
        }

        // No need to check for zero, as +x + +y != 0 && -x + -y != 0

        if ( b ) {
            xc.unshift(b);
            ++ye
        }

         // Remove trailing zeros.
        for ( a = xc.length; xc[--a] == 0; xc.pop() ) {
        }

        return y['c'] = xc, y['e'] = ye, y
    };


    /*
     * Return a Big whose value is the value of this Big raised to the power
     * 'e'. If 'e' is negative, round, if necessary, to a maximum of 'Big.DP'
     * decimal places using rounding mode 'Big.RM'.
     *
     * e {number} Integer, -MAX_POWER to MAX_POWER inclusive.
     */
    P['pow'] = function ( e ) {
        var isNeg = e < 0,
            x = new Big(this),
            y = ONE;

        if ( e !== ~~e || e < -MAX_POWER || e > MAX_POWER ) {
            throw '!pow!'
        }

        for ( e = isNeg ? -e : e; ; ) {

            if ( e & 1 ) {
                y = y['times'](x)
            }
            e >>= 1;

            if ( !e ) {
                break
            }
            x = x['times'](x)
        }

        return isNeg ? ONE['div'](y) : y
    };


    /*
     * Return a new Big whose value is the value of this Big rounded, if
     * necessary, to a maximum of 'dp' decimal places using rounding mode 'rm'.
     * If 'dp' is not specified, round to 0 decimal places.
     * If 'rm' is not specified, use 'Big.RM'.
     *
     * [dp] {number} Integer, 0 to MAX_DP inclusive.
     * [rm] 0, 1, 2 or 3 ( ROUND_DOWN, ROUND_HALF_UP, ROUND_HALF_EVEN, ROUND_UP )
     */
    P['round'] = function ( dp, rm ) {
        var x = new Big(this);

        if ( dp == null ) {
            dp = 0
        } else if ( dp !== ~~dp || dp < 0 || dp > MAX_DP ) {
            throw '!round!'
        }
        rnd( x, dp, rm == null ? Big['RM'] : rm );

        return x
    };


    /*
     * Return a new Big whose value is the square root of the value of this
     * Big, rounded, if necessary, to a maximum of 'Big.DP' decimal places
     * using rounding mode 'Big.RM'.
     */
    P['sqrt'] = function () {
        var estimate, r, approx,
            x = this,
            xc = x['c'],
            i = x['s'],
            e = x['e'],
            half = new Big('0.5');

        // Zero?
        if ( !xc[0] ) {
            return new Big(x)
        }

        // Negative?
        if ( i < 0 ) {
            throw NaN
        }

        // Estimate.
        i = Math.sqrt( x.toString() );

        // Math.sqrt underflow/overflow?
        // Pass 'x' to Math.sqrt as integer, then adjust the exponent of the result.
        if ( i == 0 || i == 1 / 0 ) {
            estimate = xc.join('');

            if ( !( estimate.length + e & 1 ) ) {
                estimate += '0'
            }

            r = new Big( Math.sqrt(estimate).toString() );
            r['e'] = ( ( ( e + 1 ) / 2 ) | 0 ) - ( e < 0 || e & 1 )
        } else {
            r = new Big( i.toString() )
        }

        i = r['e'] + ( Big['DP'] += 4 );

        // Newton-Raphson loop.
        do {
            approx = r;
            r = half['times']( approx['plus']( x['div'](approx) ) )
        } while ( approx['c'].slice( 0, i ).join('') !==
                       r['c'].slice( 0, i ).join('') );

        rnd( r, Big['DP'] -= 4, Big['RM'] );

        return r
    };


    /*
     * Return a new Big whose value is the value of this Big times the value
     * of Big 'y'.
     */
    P['times'] = function ( y ) {
        var c,
            x = this,
            xc = x['c'],
            yc = ( y = new Big( y ) )['c'],
            a = xc.length,
            b = yc.length,
            i = x['e'],
            j = y['e'];

        y['s'] = x['s'] == y['s'] ? 1 : -1;

        // Either 0?
        if ( !xc[0] || !yc[0] ) {

            return new Big( y['s'] * 0 )
        }

        y['e'] = i + j;

        if ( a < b ) {
            c = xc, xc = yc, yc = c, j = a, a = b, b = j
        }

        for ( j = a + b, c = []; j--; c.push(0) ) {
        }

        // Multiply!
        for ( i = b - 1; i > -1; i-- ) {

            for ( b = 0, j = a + i;
                  j > i;
                  b = c[j] + yc[i] * xc[j - i - 1] + b,
                  c[j--] = b % 10 | 0,
                  b = b / 10 | 0 ) {
            }

            if ( b ) {
                c[j] = ( c[j] + b ) % 10
            }
        }

        b && ++y['e'];

        // Remove any leading zero.
        !c[0] && c.shift();

        // Remove trailing zeros.
        for ( j = c.length; !c[--j]; c.pop() ) {
        }

        return y['c'] = c, y
    };


    /*
     * Return a string representing the value of this Big.
     * Return exponential notation if this Big has a positive exponent equal
     * to or greater than 'TO_EXP_POS', or a negative exponent equal to or less
     * than 'TO_EXP_NEG'.
     */
    P['toString'] = P['valueOf'] = function () {
        var x = this,
            e = x['e'],
            str = x['c'].join(''),
            strL = str.length;

        // Exponential notation?
        if ( e <= TO_EXP_NEG || e >= TO_EXP_POS ) {
            str = str.charAt(0) + ( strL > 1 ?  '.' + str.slice(1) : '' ) +
              ( e < 0 ? 'e' : 'e+' ) + e

        // Negative exponent?
        } else if ( e < 0 ) {

        // Prepend zeros.
            for ( ; ++e; str = '0' + str ) {
            }
            str = '0.' + str

        // Positive exponent?
        } else if ( e > 0 ) {

            if ( ++e > strL ) {

                // Append zeros.
                for ( e -= strL; e-- ; str += '0' ) {
                }
            } else if ( e < strL ) {
                str = str.slice( 0, e ) + '.' + str.slice(e)
            }

        // Exponent zero.
        } else if ( strL > 1 ) {
            str = str.charAt(0) + '.' + str.slice(1)
        }

        // Avoid '-0'
        return x['s'] < 0 && x['c'][0] ? '-' + str : str
    };


    /*
     ***************************************************************************
     * If 'toExponential', 'toFixed', 'toPrecision' and 'format' are not
     * required they can safely be commented-out or deleted. No redundant code
     * will be left. 'format' is used only by 'toExponential', 'toFixed' and
     * 'toPrecision'.
     ***************************************************************************
     */


    /*
     * PRIVATE FUNCTION
     *
     * Return a string representing the value of Big 'x' in normal or
     * exponential notation to a fixed number of decimal places or significant
     * digits 'dp'.
     * (Called by toString, toExponential, toFixed and toPrecision.)
     *
     * x {Big} The Big to format.
     * dp {number} Integer, 0 to MAX_DP inclusive.
     * toE {number} undefined (toFixed), 1 (toExponential) or 2 (toPrecision).
     */
    function format( x, dp, toE ) {
        // The index (in normal notation) of the digit that may be rounded up.
        var i = dp - ( x = new Big(x) )['e'],
            c = x['c'];

        // Round?
        if ( c.length > ++dp ) {
            rnd( x, i, Big['RM'] )
        }

        // Recalculate 'i' if toFixed as 'x.e' may have changed if value rounded up.
        i = !c[0] ? i + 1 : toE ? dp : ( c = x['c'], x['e'] + i + 1 );

        // Append zeros?
        for ( ; c.length < i; c.push(0) ) {
        }
        i = x['e'];

        /*
         * 'toPrecision' returns exponential notation if the number of
         * significant digits specified is less than the number of digits
         * necessary to represent the integer part of the value in normal
         * notation.
         */
        return toE == 1 || toE == 2 && ( dp <= i || i <= TO_EXP_NEG )

            // Exponential notation.
            ? ( x['s'] < 0 && c[0] ? '-' : '' ) + ( c.length > 1
              ? ( c.splice( 1, 0, '.' ), c.join('') )
              : c[0] ) + ( i < 0 ? 'e' : 'e+' ) + i

            // Normal notation.
            : x.toString()
    }


    /*
     * Return a string representing the value of this Big in exponential
     * notation to 'dp' fixed decimal places and rounded, if necessary, using
     * 'Big.RM'.
     *
     * [dp] {number} Integer, 0 to MAX_DP inclusive.
     */
    P['toExponential'] = function ( dp ) {

        if ( dp == null ) {
            dp = this['c'].length - 1
        } else if ( dp !== ~~dp || dp < 0 || dp > MAX_DP ) {
            throw '!toExp!'
        }

        return format( this, dp, 1 )
    };


    /*
     * Return a string representing the value of this Big in normal notation
     * to 'dp' fixed decimal places and rounded, if necessary, using 'Big.RM'.
     *
     * [dp] {number} Integer, 0 to MAX_DP inclusive.
     */
    P['toFixed'] = function ( dp ) {
        var str,
            x = this,
            neg = TO_EXP_NEG,
            pos = TO_EXP_POS;

        TO_EXP_NEG = -( TO_EXP_POS = 1 / 0 );

        if ( dp == null ) {
            str = x.toString()
        } else if ( dp === ~~dp && dp >= 0 && dp <= MAX_DP ) {
            str = format( x, x['e'] + dp );

            // (-0).toFixed() is '0', but (-0.1).toFixed() is '-0'.
            // (-0).toFixed(1) is '0.0', but (-0.01).toFixed(1) is '-0.0'.
            if ( x['s'] < 0 && x['c'][0] && str.indexOf('-') < 0 ) {
                // As e.g. -0.5 if rounded to -0 will cause toString to omit the minus sign.
                str = '-' + str
            }
        }
        TO_EXP_NEG = neg, TO_EXP_POS = pos;

        if ( !str ) {
            throw '!toFix!'
        }

        return str
    };


    /*
     * Return a string representing the value of this Big to 'sd' significant
     * digits and rounded, if necessary, using 'Big.RM'. If 'sd' is less than
     * the number of digits necessary to represent the integer part of the value
     * in normal notation, then use exponential notation.
     *
     * sd {number} Integer, 1 to MAX_DP inclusive.
     */
    P['toPrecision'] = function ( sd ) {

        if ( sd == null ) {
            return this.toString()
        } else if ( sd !== ~~sd || sd < 1 || sd > MAX_DP ) {
            throw '!toPre!'
        }

        return format( this, sd - 1, 2 )
    };


    // EXPORT


    // Node and other CommonJS-like environments that support module.exports.
    if ( typeof module !== 'undefined' && module.exports ) {
        module.exports = Big

    //AMD.
    } else if ( typeof define == 'function' && define.amd ) {
        define('node_modules/big/big',[], function () {
            return Big
        })

    //Browser.
    } else {
        global['Big'] = Big
    }

})( this );

define('src/cscore',[
	'./csbase',
	'./csutil',
	'node_modules/big/big'
], function(Base, Util, Big) {
	var Log = Base.Log,
		prefix = Util.configuratorPrefix,
		ORIGINAL_OPTIONS = 'originalOptions',
		HIDDEN = 'hidden',
		READ_ONLY = 'readOnly',
		RULE_LOCK = 'ruleLock',
		PREVIOUS_SELECTED = 'previousSelected',
		PREVIOUS_VALUE = 'previousValue',
		REQUIRED_CLASS = 'requiredInput',
		READONLY_PLACEHOLDER = 'roPlaceholder',
		EMPTY = this.EMPTY = '',
		BIG_JS_ROUND_HALF_EVEN = 2,
		DATA_TYPE_DECIMAL = 'Decimal',
		DATA_TYPE_DOUBLE = 'Double',
		DATA_TYPE_INTEGER = 'Integer',
		LOOKUP_QUERY_TIMEOUT_MILLIS = 10000;

	var FREQUENCIES = {
		'annual': 1,
		'bi-annual': 2,
		'quarterly': 4,
		'monthly': 12,
		'weekly': 52,
		'daily': 365
	};

	var FREQUENCY_NAMES = {
		'1': 'annually',
		'2': 'bi-annually',
		'4': 'quarterly',
		'12': 'monthly',
		'52': 'weekly',
		'365': 'daily'
	};

	var PERIODS = {
		'year': 1,
		'quarter': 4,
		'month': 12,
		'week': 52,
		'day': 365
	};

	var PERIOD_NAMES = {
		'1': 'year',
		'4': 'quarter',
		'12': 'month',
		'52': 'week',
		'365': 'day'
	};

	var CONFIG_PROPERTY_ACCESSORS = {
		'attrname' : function(wrapper) {
			return wrapper.config[prefix + 'Attribute_Name__c'];
		},
		'billingfrequency' : function(wrapper) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Billing_Frequency__c'];
			} else {
				wrapper.config[prefix + 'Billing_Frequency__c'] = value;
			}
		},
		'contractterm' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Contract_Term__c'];
			} else {
				wrapper.config[prefix + 'Contract_Term__c'] = value;
			}
		},
		'contracttermperiod' : function(wrapper) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Contract_Term_Period__c'];
			} else {
				wrapper.config[prefix + 'Contract_Term_Period__c'] = value;
			}
		},
		'contracttermperiodname' : function(wrapper) {
			return getPeriodName(wrapper.config[prefix + 'Contract_Term_Period__c']);
		},
		'index' : function(wrapper) {
			return wrapper.config[prefix + 'Index__c'];
		},
		'name' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.config.Name;
			} else {
				wrapper.config.Name = value;
			}
		},
		'product' : function(wrapper) {
			var defId = wrapper.config[prefix + 'Product_Definition__c'],
				def = Service.getProductIndex()[all][defId];
			if (!def) {
				Log.error('Could not find product definition: ' + defId);
				return;
			}
			return def.Name;
		},
		'recurrence' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Recurrence_Frequency__c'];
			} else {
				wrapper.config[prefix + 'Recurrence_Frequency__c'] = value;
			}
		},
		'recurrencename' : function(wrapper) {
			return getFrequencyName(wrapper.config[prefix + 'Recurrence_Frequency__c']);
		},
		'status' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Configuration_Status__c'];
			} else {
				wrapper.config[prefix + 'Configuration_Status__c'] = value;
			}
		},
		'validationmessage' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.config[prefix + 'Validation_Message__c'];
			} else {
				wrapper.config[prefix + 'Validation_Message__c'] = value;
			}
		}
	};

	var ATTRIBUTE_FIELD_ACCESSORS = {
		'name' : function(wrapper, value) {
			var definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
			if (definition) {
				if (value === undefined) {
					return definition.Name;
				} else {
					definition.Name = value;
					return;
				}
			}
			Log.error('Could not find definition for attribute wrapper', wrapper);
		},

		'baseprice' : function(wrapper, value) {
			var definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
			if (definition) {
				if (value === undefined) {
					return parseFloat(definition[prefix + 'Base_Price__c']) || 0;
				} else {
					definition[prefix + 'Base_Price__c'] = parseFloat(value) || undefined;
					return;
				}
			}
			Log.error('Could not find definition for attribute wrapper', wrapper);
		},

		// backwards compatibility
		'configname' : function(wrapper, value) {
			var config = wrapper.config;
			if (config) {
				if (value === undefined) {
					return config.Name;
				} else {
					config.Name = value;
					return;
				}
			}
			Log.error('Could not find config for wrapper', wrapper);
		},

		'displayvalue' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'Display_Value__c'];
			} else {
				wrapper.attr[prefix + 'Display_Value__c'] = value;
			}
		},

		'price' : function(wrapper, value) {
			if (value === undefined) {
				return parseFloat(wrapper.attr[prefix + 'Price__c']) || 0;
			} else {
				wrapper.attr[prefix + 'Price__c'] = parseFloat(value) || undefined;
			}
		},

		'active' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'is_active__c'];
			} else {
				wrapper.attr[prefix + 'is_active__c'] = getBooleanValue(value);
			}
		},

		'islineitem' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'Is_Line_Item__c'];
			} else {
				wrapper.attr[prefix + 'Is_Line_Item__c'] = getBooleanValue(value);
			}
		},

		'defislineitem' : function(wrapper) {
			var definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
			if (definition) {
				return definition[prefix + 'Is_Line_Item__c'];
			}
			Log.error('Could not find definition for attribute wrapper', wrapper);
		},

		'lineitemdescription' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'Line_Item_Description__c'];
			} else {
				wrapper.attr[prefix + 'Line_Item_Description__c'] = value;
			}
		},

		'lineitemsequence' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'Line_Item_Sequence__c'];
			} else {
				wrapper.attr[prefix + 'Line_Item_Sequence__c'] = value;
			}
		},

		'isrecurring' : function(wrapper, value) {
			var definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
			if (definition) {
				if (value === undefined) {
					return definition[prefix + 'Recurring__c'];
				} else {
					definition[prefix + 'Recurring__c'] = value;
					return;
				}
			}
			Log.error('Could not find definition for attribute wrapper', wrapper);
		},

		'isrequired' : function(wrapper, value) {
			if (value === undefined) {
				return wrapper.attr[prefix + 'Is_Required__c'];
			} else {
				CS.binding.update(wrapper.reference, {required: getBooleanValue(value)});
			}
		}
	};


	var Service;

	function getBooleanValue(value) {
		if (typeof value === 'string') {
			return value && value.toLowerCase() === 'true';
		}
		return value ? true : false;
	}

	function getPackageNamespace() {
		var namespaces = ['cscfga', 'cscfgc'],
			namespace,
			idx = namespaces.length;

		while(idx--) {
			namespace = window[namespaces[idx]];
			if (namespace && namespace.ConfiguratorExtension) return namespace;
		}

		return window;
	}

	function getFrequencyName(val) {
		return FREQUENCY_NAMES[val] || '';
	}

	function getPeriodName(val) {
		return PERIOD_NAMES[val] || '';
	}

	function getPeriodValueForName(name) {
		if (!name) return undefined;
		return PERIODS[name.toLowerCase()];
	}

	function getFrequencyValueForName(name) {
		if (!name) return undefined;
		return FREQUENCIES[name.toLowerCase()];
	}

	/* Core API */

	var CS = window.CS ? window.CS : window.CS = {};
	(function(){
		/**
			@module Core
			@namespace CS
			@exports CS
			@requires Base
			@requires Util
		*/
		var api = {},
			loggingEnabled = false,
			loadingOverlayEnabled = true,
			progressBarImageUrl = '',
			infoMessages = {},
			warningMessages = {},
			lookupQueryCache,
			executeAfterLookupQueriesQueue,
			lookupQueryQueueTimer,
			lookupQueryStartTime,
			lookupQuerySerial = 1,
			cachedLookupValues,
			multiSelectLookups;

		/**
		 	Removes the info message from the configuration screen
		 */
		this.clearInfo = clearInfo;
		function clearInfo() {
			infoMessages = {};
			jQuery('#CSInfoMessageBox').removeClass('visible');
			jQuery('#CSInfoMessage').html('');
		}

		/**
		 	 Removes the warning message from the configuration screen
		 */
		this.clearWarning = clearWarning;
		function clearWarning() {
			warningMessages = {};
			jQuery('#CSValidationMessageBox').removeClass('visible');
			jQuery('#CSValidationMessage').html('');
		}

		/**
		 *	Constrains the options of the select list in the attribute 'ref' to those contained in 'validOptions'.
		 *	Where:	'ref' is an attribute reference e.g. My_Att_0
		 *			'validOptions' is a list of valid options keys (must match keys in the attribute definition select options map to be shown)
		 *			'suppressEvent' if true, the change event is suppressed, i.e. the rules are not fired
		 */
		this.constrainList = constrainList;
		function constrainList(ref, validOptions) {
			var wrapper = getAttributeWrapper(ref),
				prodDefId = wrapper.definition ? wrapper.definition[prefix + 'Product_Definition__c'] : undefined,
				allOptionsMap = wrapper ? CS.Service.getProductIndex(prodDefId).selectOptionsMapByAttribute[wrapper.definitionId] : undefined,
				newOptions = [];

			if (!wrapper) {
				return;
			}
			if (!allOptionsMap) {
				Log.error('Could not find options for attribute reference', ref);
				return;
			}

			for (var i = 0; i < validOptions.length; i++) {
				var valid = validOptions[i],
					option = valid ? allOptionsMap[valid[0]] : undefined;
				if (option) {
					newOptions.push(option);
				}
			}

			newOptions.sort(function(a,b) {
				return a[prefix + 'Sequence__c'] > b[prefix + 'Sequence__c'] ? 1 : a[prefix + 'Sequence__c'] === b[prefix + 'Sequence__c'] ? 0 : -1;
			});

			CS.binding.update(ref, {selectOptions: newOptions});
		}

		/**
		 *	Displays the message in the info message box. Appends the message to any others already being shown.
		 */
		this.displayInfo = displayInfo;
		function displayInfo(value) {
			if (value && value.isCallback) {
				value.applyValue = function(data) {
					var currentVal = jQuery(getId(id)).val();
					var val = data[value.fieldName];
					if (val !== 0 && val !== false && !val) val = '';
					if (val != currentVal) {
						displayInfo(val);
					}
				};
			} else {
				var h = CS.Util.hashCode(value);
				infoMessages[h] = value;
				var msgBox = jQuery('#CSInfoMessageBox').addClass('visible');
				if (msgBox.find('span').size() === 0) {
					msgBox.prepend('<span class="icon-info-circle"></span>');
				}
				var html = '';
				for (h in infoMessages) {
					html += '<p>' + infoMessages[h] + '</p>';
				}
				jQuery('#CSInfoMessage').html(html);
			}
		}

		this.disableLoadingOverlay = function disableLoadingOverlay() {
			this.loadingOverlayEnabled = false;
		};

		this.enableLoadingOverlay = function enableLoadingOverlay() {
			this.loadingOverlayEnabled = true;
		};

		this.getFrequencyName = getFrequencyName;

		this.getFrequencyValueForName = getFrequencyValueForName;
		
		this.getPeriodName = getPeriodName;

		this.getPeriodValueForName = getPeriodValueForName;

		/**
		 * Initialises for a configuration
		 */
		this.init = init;
		function init(delegatedFunctions, domSelector, rootProductId, configurationToLoad, callback) {
			api = delegatedFunctions;
			this.cachedLookupValues = cachedLookupValues = {};
			this.getFrequencyName = getFrequencyName;
			this.getPeriodName = getPeriodName;
			this.getPeriodValueForName = getPeriodValueForName;
			this.executeAfterLookupQueriesQueue = executeAfterLookupQueriesQueue = [];
			this.executeQueryQueueIndex = executeQueryQueueIndex = {};
			this.infoMessages = infoMessages = {};
			this.warningMessages = warningMessages = {};
			this.lookupQueryCache = lookupQueryCache = {};
			this.lookupQueryQueueTimer = lookupQueryQueueTimer = null;
			this.lookupQueryStartTime = lookupQueryStartTime = null;
			if (!this.lookupRecords) {
				this.lookupRecords = {};
			}
			this.multiSelectLookups = multiSelectLookups = {};
			this.Service = {};
			CS.Rules.resetRules();
			Service = this.Service = CS.SVC.init(delegatedFunctions, domSelector, rootProductId, configurationToLoad, function serviceInitCallback() {
				if (!CS.screens) {
					CS.screens = {};
				}
				jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(CS.Service.getProductIndex()));
				if (callback) {
					callback();
				}
			});
			if (!CS.indicator) {
				CS.indicator = {
					start: function() {},
					stop: function() {}
				};
			}
		}

		this.isLoadingOverlayEnabled = isLoadingOverlayEnabled;
		function isLoadingOverlayEnabled() {
			return loadingOverlayEnabled;
		}

		/**
		 *	Queues a function to be executed once any currently outstanding LookupQueries have completed.
		 */
		this.executeOnLookupQueriesDone = executeOnLookupQueriesDone;
		function executeOnLookupQueriesDone(callback, name) {
			if (typeof(callback) != 'function') {
				throw 'Invalid arguments: CS.executeOnLookupQueriesDone(function, [name])';
			}
			if (!name) {
				name = callback.name;
				if (!name) {
					return Log.error('No function name specified', callback, name);
				}
			}

			// IE does not carry a function name
			if (!callback.name) {
				callback.name = name;
			}

			if (executeQueryQueueIndex[name]) {
				log('Function ' + name + ' already queued');
			} else {
				log('Queuing function after lookup queries');
				executeAfterLookupQueriesQueue.push(callback);
				executeQueryQueueIndex[name] = name;
			}

			runFunctionsQueuedForLookupQueries();
		}

		/**
		 *	Waits until any active LookupQueries are complete then executes any
		 *	functions which were queued.
		 */
		var pageLoad = true, submissionExecute = false, indicatorTimeout = 1000;
		this.runFunctionsQueuedForLookupQueries = runFunctionsQueuedForLookupQueries;
		this.setIndicatorTimeout = function( miliseconds ){
			indicatorTimeout = miliseconds;
		};

		function runFunctionsQueuedForLookupQueries() {
			if (pageLoad || submissionExecute) {
//				CS.indicator.start('#indicatorContainer', 50);
			} else{
//				CS.indicator.start('#indicatorContainer', indicatorTimeout);
			}
			if (lookupQueriesAreQueued()) {
				log('Waiting for lookup queries to complete...');
				if (!lookupQueryStartTime) {
					lookupQueryStartTime = new Date().getTime();
				}
				if (lookupQueryQueueTimer != null) {
					lookupQueryQueueTimer = setTimeout(runFunctionsQueuedForLookupQueries, 100);
				}
				if (new Date().getTime() - lookupQueryStartTime > LOOKUP_QUERY_TIMEOUT_MILLIS) {
					abortLookupQueries();
				}
				return;
			} else {
				log('>>> No lookup queries remain, executing function queue... ');
				lookupQueryQueueTimer = null;
				lookupQueryStartTime = null;
				if (executeAfterLookupQueriesQueue.length === 0) {
					log('Function queue empty');
					pageLoad = false;
					return;
				} else {
					log('Starting queued function execution...');
				}
				var i = executeAfterLookupQueriesQueue.length,
					f;
				while (i--) {
					try {
						f = executeAfterLookupQueriesQueue.shift();
						executeQueryQueueIndex[f.name] = undefined;
						log('Executing queued function: ' + f.name);
						f();
					} catch(e) {
						CS.Log.error(e);
					}
				}
				if (!lookupQueriesAreQueued() && !submissionExecute) {
					pageLoad = false;
				}
			}
		}

		/**
		 *	Returns true if there are currently LookupQueries which have not yet completed.
		 */
		this.lookupQueriesAreQueued = lookupQueriesAreQueued;
		function lookupQueriesAreQueued() {
			for (var query in CS.lookupQueryCache) {
				if (CS.lookupQueryCache[query].callbacks.length > 0) return true;
			}
			return false;
		}

		function abortLookupQueries() {
			Log.error('Timeout exceeded - aborting any outstanding lookup queries');
			for (var name in CS.lookupQueryCache) {
				var query = CS.lookupQueryCache[name];
				if (query.status != 'ready') {
					if (query.callbacks) {
						query.callbacks.length = 0;
					}
					query.status = 'ready';
				}
			}
		}

		/**
		 *	Diagnostic function to provide a run down of LookupQuery activity.
		 */
		this.getLookupQueryStats = getLookupQueryStats;
		function getLookupQueryStats() {
			var stats = {
				numActiveQueries: 0,
				activeQueries: {},
				numCompletedQueries: 0,
				completedQueries: {}
			};

			for (var queryName in lookupQueryCache) {
				var query = lookupQueryCache[queryName];

				if (query.callbacks.length > 0) {
					stats.numActiveQueries++;
					stats.activeQueries[queryName] = query;
				} else {
					stats.numCompletedQueries++;
					stats.completedQueries[queryName] = query;
				}
			}
			return stats;
		}

		/**
		 * Legacy function to log message. Deprecated in favour of CS.Log.
		 */
		this.log = log;
		function log() {
			Log.info.apply(Log, arguments);
		}

		/**
		 *	Returns true if the String str begins with String value.
		 *  Alias of CS.Util.startsWith, preserved under CS namespace
		 *	for backwards compatibility.
		 */
		var startsWith = this.startsWith = Util.startsWith;

		/**
		 *	Returns true if the String str ends with String value.
		 *  Alias of CS.Util.startsWith, preserved under CS namespace
		 *	for backwards compatibility.
		 */
		var endsWith = this.endsWith = Util.endsWith;

		/**
		 *	Disables the attribute at the supplied reference.
		 */
		this.disableAttribute = disableAttribute;
		function disableAttribute(id) {
			CS.binding.update(id, {active: false});
		}

		/**
		 *	Makes the attribute at the supplied reference read only.
		 */
		this.makeAttributeReadOnly = makeAttributeReadOnly;
		function makeAttributeReadOnly(id) {
			CS.binding.update(id, {readOnly: true});
		}

		/**
		 *	Marks the configuration invalid with the message displayed in the warning.
		 */
		this.markConfigurationInvalid = markConfigurationInvalid;
		function markConfigurationInvalid(id, value) {
			if (value === undefined) {
				value = id; // allow id param to be dropped
				id = '';
			}
			if (value && value.isCallback) {
				value.applyValue = function(data) {
					var val = data[value.fieldName];
					markConfigurationInvalid(id, val);
				};
			} else {
				var h = Util.hashCode(value);
				warningMessages[h] = value;
				var msgBox = jQuery('#CSValidationMessageBox').addClass('visible');
				if (msgBox.find('span').size() === 0) {
					msgBox.prepend('<span class="icon-attention"></span>');
				}
				var html = '';
				for (h in warningMessages) {
					html += '<p>' + warningMessages[h] + '</p>';
				}
				jQuery('#CSValidationMessage').html(html);
				setConfigurationProperty(id, 'status', 'Incomplete');
				setConfigurationProperty(id, 'validationmessage', '<p>' + value + '</p>');
			}
		}

		function getAttributeDisplayValue(id) {
			var wrapper = getAttributeWrapper(id);
			if (wrapper) {
				return wrapper.attr[prefix + 'Display_Value__c'] ? wrapper.attr[prefix + 'Display_Value__c'] : wrapper.attr[prefix + 'Value__c'];
			}
		}
		this.getAttributeDisplayValue = getAttributeDisplayValue;

		function getAttributeField(id, fieldName) {
			if (fieldName == null) return null;

			var value,
				numVal,
				accessor = ATTRIBUTE_FIELD_ACCESSORS[fieldName.toLowerCase()],
				wrapper = getAttributeWrapper(id);

			if (wrapper) {
				value = accessor ? accessor(wrapper) : (wrapper.attributeFields[fieldName] ? wrapper.attributeFields[fieldName].cscfga__Value__c : undefined);
				if (value === undefined) {
					if (!accessor || !(fieldName in wrapper.attributeFields)) {
						Log.error('Could not find field ' + fieldName + ' for attribute ' + id);
					}
				} else {
					// simple parse-based duck typing insufficient (returns Strings starting with numbers as numbers)
					/*numVal = parseFloat(value);
					if (!isNaN(numVal)) {
						value = numVal;
					}*/
				}
				return value;
			}
		}
		this.getAttributeField = this.getAttributeFieldValue = getAttributeField;

		function setAttributeField(id, fieldName, value) {
			if (value && value.isCallback) {
				value.applyValue = function(data) {
					var currentVal = jQuery(getId(id)).val();
					var val = data[value.fieldName];
					if (val !== 0 && val !== false && !val) val = '';
					if (val != currentVal) {
						setAttributeField(id, fieldName, val);
					}
				};
			} else {
				if (fieldName == null) return;

				var accessor = ATTRIBUTE_FIELD_ACCESSORS[fieldName.toLowerCase()],
					wrapper = getAttributeWrapper(id);

				if (wrapper) {
					if (accessor) {
						accessor(wrapper, value);
					} else {
						Service.setAttributeField(wrapper, fieldName, value);
					}
				}
			}
		}
		this.setAttributeField = setAttributeField;

		function getAttributeValue(id, dataType) {
			var wrapper = getAttributeWrapper(id),
				attr,
				val;
			if (!wrapper) return;

			attr = wrapper.attr;

			if (!getAttributeField(id, 'active')) {
				return '';
			}

			if (!dataType) {
				var definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
				if (!definition) {
					Log.error('Could not find definition for attribute ' + id + ' - proceeding without type hint');
				} else {
					dataType = definition[prefix + 'Data_Type__c'];
				}
			}

			if (dataType === 'Integer') val = parseInt(attr[prefix + 'Value__c'], 10);
			if (dataType === 'Double') val = parseFloat(attr[prefix + 'Value__c'], 10);

			if (!val && val !== 0) val = attr[prefix + 'Value__c'];
			return val === null ? '' : val;
		}
		this.getAttributeValue = getAttributeValue;

		function setAttributeValue(id, value, suppressEvent) {
			if (value && value.isCallback) {
				value.applyValue = function(data) {
					if (cachedLookupValues[id] === undefined) cachedLookupValues[id] = getAttributeValue(id);
					var currentVal = convertValueForAttributeDataType(id, getAttributeValue(id));
					var val = convertValueForAttributeDataType(id, data[value.fieldName]);
					if (val !== 0 && val !== false && !val) val = '';
					CS.Log.info('LookupQuery setAttributeValue ', value.fieldName, '->', val);
					if ('' + val != currentVal) {
						setAttributeValue(id, val, suppressEvent);
						cachedLookupValues[id] = val;
						log('Dynamic lookup result requires rule evaluation: ' + id + ' - ' + val + ' (' + currentVal + ')');
						//CS.rules.evaluateAllRules();
					}
				};
			} else {
				var wrapper = getAttributeWrapper(id),
					oldValue = getAttributeValue(id),
					convertedValue = convertValueForAttributeDataType(id, value);

				if (wrapper) {
					CS.binding.update(id, {value: convertedValue, suppressRules: suppressEvent});
					Log.debug('>> Set ' + id + ': ' + convertedValue + ' (' + oldValue + ')');
					if (!suppressEvent) {
						CS.Rules.fireChange(wrapper);
					}
				}
			}
		}
		this.setAttributeValue = this.setAttribute = this.setCalculation = setAttributeValue; // maintain compatibility with original API

		function convertValueForAttributeDataType(ref, value) {
			var wrapper = getAttributeWrapper(ref),
				definition = wrapper ? (wrapper.definition || Service.getProductIndex().all[wrapper.definitionId]) : undefined,
				dataType = definition ? definition.cscfga__Data_Type__c : undefined,
				scale = definition ? definition.cscfga__Scale__c : undefined;

			if (!wrapper || !definition) {
				Log.error('convertValueForAttributeDataType: could not find wrapper or definition for ref', ref);
				return undefined;
			}

			if (value && dataType == DATA_TYPE_DECIMAL && scale > 0) {
				value = roundValue(value, scale);
			}

			return value;
		}

		function roundValue(value, scale) {
			if (isNaN(value) || !isFinite(value)) {
				log('roundValue: replacing ' + value + ' with ""');
				return '';
			}
			try {
				var checkedValue = Big(value);

				if (!isNaN(checkedValue)) {
					value = checkedValue.round(scale, BIG_JS_ROUND_HALF_EVEN).toFixed(scale);
				}
			} catch (e) {}

			return value;
		}

		function getAttributeWrapper(id) {
			var key = endsWith(id, ':') ? id.substring(0, id.length-1) : id,
				wrapper = Service.config[key];

			if (!wrapper) {
				Log.error('Could not find attribute ' + key);
				return;
			}

			return wrapper;
		}
		this.getAttributeWrapper = getAttributeWrapper;

		function findAttributeWrapperByName(baseRef, name) {
			var fullRef = Util.generateReference(name, {ref: baseRef}),
				wrapper = Service.config[fullRef];

			if (!wrapper) {
				Log.error('No Attribute Wrapper found for reference ', fullRef, baseRef, name);
			}

			return wrapper;
		}
		this.findAttributeWrapperByName = findAttributeWrapperByName;

		function setCheckbox(id, value, suppressEvent) {
			setAttributeValue(id, value, suppressEvent);
		}
		this.setCheckbox = setCheckbox;

		function setTextDisplay(id, value, suppressEvent) {
			setAttributeValue(id, value, suppressEvent);
		}
		this.setTextDisplay = setTextDisplay;

		function getLookupValue(ref, fieldName, defaultValue) {
			var wrapper = getAttributeWrapper(ref),
				data = wrapper ? CS.lookupRecords[wrapper.attr[prefix + 'Value__c']] : undefined,
				value = null;

			if (!wrapper) {
				return;
			}

			if (!data) {
				Log.info('No lookup data found, using default value', ref, fieldName, defaultValue);
				value = defaultValue;
			} else {
				if (data[fieldName]) {
					value = data[fieldName];
				} else {
					// case insensitive lookup
					for (var field in data) {
						if (field.toLowerCase() == fieldName) {
							value = data[field];
							break;
						}
					}
				}
			}

			Log.info('Lookup value', ref, fieldName, data ? data.Id : '');
			return value;
		}
		this.getLookupValue = getLookupValue;

        //begin
       function getDynamicLookupValue(queryID, fieldName, productDefinitionID, attrAbsoluteReferenceAsId) {
	CS.Log.info('Dynamic lookup: ', queryID, fieldName, productDefinitionID, attrAbsoluteReferenceAsId);
	var configPrefix = '';
	attrAbsoluteReferenceAsId = attrAbsoluteReferenceAsId || '';
	var n = attrAbsoluteReferenceAsId.lastIndexOf(":");
	if (n != -1) {
		configPrefix = attrAbsoluteReferenceAsId.substr(0, n);
	}

	var namespace = getPackageNamespace();
	var lookupQuery = api.lookupQuery ? api.lookupQuery : namespace.ConfiguratorExtension ? namespace.ConfiguratorExtension.lookupQuery : undefined;

	if (!lookupQuery) {
		Log.warn('LookupQuery not available');
		return;
	}

	var dynamicFilterMap = {};
	var bConfigAttribute = false;
	var attrRef;
	var index = CS.Service.getProductIndex(productDefinitionID),
		lookupQueryObj = index.lookupQueriesByName[queryID],
		referencedAttributes = lookupQueryObj ? JSON.parse(lookupQueryObj[prefix + 'Referenced_Attributes__c']) : [];

	jQuery.each(Service.config, function(i, it) {
		if (it.attr) {
			bConfigAttribute = false;
			attrRef = it.reference;
			if (configPrefix !== '' && attrRef.lastIndexOf(configPrefix) != -1) {
				if (attrRef.substring(n).split(":").length < 3) {
					bConfigAttribute = true;
				}
			}
			if (configPrefix === '' && attrRef.lastIndexOf(':') == -1) {
				bConfigAttribute = true;
			}
			if (bConfigAttribute) {
				var name = it.attr.Name;
				if (lookupQueryObj === undefined) {
					dynamicFilterMap[name] = it.attr[prefix + 'Value__c'];
				} else {
					if (jQuery.inArray(name, referencedAttributes) !== -1) {
						dynamicFilterMap[name] = it.attr[prefix + 'Value__c'];
					}
				}
			}
		}
	});

	var queryProxy = {
		isCallback: true,
		fieldName: fieldName.toLowerCase(),
		applyValue: function(value) {
			Log.error('Callback applyValue not defined!');
		},
		setError: function(error) {
			Log.error('Could not update dynamic lookup: ' + error);
		}
	};

	// build cache key: the suffix is a json representation of the dynamicFilterMap with the keys sorted 
	// to make sure keys are identical for equal dynamicFilterMap objects.
	var cacheKeyElements = [];
	jQuery.each(dynamicFilterMap, function(name, value) {
		cacheKeyElement = {};
		cacheKeyElement[name] = value;
		cacheKeyElements.push(JSON.stringify(cacheKeyElement));
	});
	cacheKeyElements.sort();
	var queryIDCacheKey = queryID + '-' + JSON.stringify(cacheKeyElements);

	var cached = CS.lookupQueryCache[queryIDCacheKey];
	if (!cached) cached = CS.lookupQueryCache[queryIDCacheKey] = {callbacks:[]};

	if (cached.params && _.isEqual(cached.params, dynamicFilterMap)) {
		Log.info('Using cached dynamic lookup value for ' + fieldName + ': ', (cached.data ? cached.data[fieldName] : undefined));
		setTimeout(function() {queryProxy.applyValue(cached.data, {status: 'cached'});}, 100);
	} else {
		CS.lookupQueryCache[queryIDCacheKey].callbacks.push(queryProxy);
		if (cached.status == 'requested') {
			log('Queued callback for: ' + fieldName);
		} else {
			var queryCallback = function(result, event) {
				var data = {},
					callback;
				if (event.status) {
					mapLookupResult(data, result, "");
					log('>> Received dynamic lookup value for ' + queryID + ' and ', dynamicFilterMap);
					cached.params = dynamicFilterMap;
					cached.data = data;
					while (cached.callbacks.length > 0) {
						callback = cached.callbacks[0];
						try {
							callback.applyValue(data);
						} catch (e) {
							Log.error('Error processing callback:', e.message, e);
						}
						cached.callbacks.shift(); // don't shift before applying so that callback still shows up until processing completed;
					}
				} else {
					cached.params = dynamicFilterMap;
					cached.data = {};
					while (cached.callbacks.length > 0) {
						callback = cached.callbacks[0];
						try {
							callback.setError(event.message);
						} catch (e) {
							Log.error('Error in callback error handler:', e.message, e);
						}
						cached.callbacks.shift(); // don't shift before applying so that callback still shows up until processing completed;
					}
				}
				cached.status = 'ready';
				runFunctionsQueuedForLookupQueries();
			};

			log('>> Values have changed on ' + queryID + ':', cached.params, dynamicFilterMap);
			//log('>> New remote request for field ' + fieldName);
			lookupQuery(
				queryID, dynamicFilterMap, productDefinitionID,
				queryCallback,
				{escape:true}
			);
			cached.status = 'requested';
		}
	}
	return queryProxy;
}
        //end update
		
		this.getDynamicLookupValue = getDynamicLookupValue;

		function mapLookupResult(data, result, prefix) {
			for (var key in result) {
				var datum = result[key];
				var dataKey = prefix + key.toLowerCase();

				data[dataKey] = datum;

				if (datum && typeof datum === 'object') {
					mapLookupResult(data, datum, dataKey + '.');
				}
			}
		}

		function getLineItems() {
			var lineItems = [];
			jQuery.each(CS.Service.config, function(i, it) {
				if (it.attr && it.attr[prefix + 'Is_Line_Item__c'] && it.attr[prefix + 'is_active__c']) lineItems.push(it);
			});
			lineItems.sort(function(a, b) {
				var aseq = a.attr[prefix + 'Line_Item_Sequence__c'],
					bseq = b.attr[prefix + 'Line_Item_Sequence__c'];
				return aseq > bseq ? 1 : aseq == bseq ? 0 : -1;
			});
			return lineItems;
		}
		this.getLineItems = getLineItems;

		function countRelatedProducts(id) {
			var wrapper = Service.config[id];
			if (!wrapper) {
				CS.Log.info('Attribute ' + id + ' not found');
				return 0;
			}
			return wrapper.relatedProducts.length;
		}
		this.countRelatedProducts = countRelatedProducts;

		function setRecurrenceFrequency(id, value) {
			var val = null;
			if (value != null) {
				val = parseInt(value, 10);
				if (!val && val !== 0) val = FREQUENCIES[value.toLowerCase()];
			}
			setConfigurationProperty(id, 'Recurrence_Frequency__c', val);
		}
		this.setRecurrenceFrequency = setRecurrenceFrequency;

		function setBillingFrequency(id, value) {
			var val = null;
			if (value != null) {
				val = parseInt(value, 10);
				if (!val && val !== 0) val = FREQUENCIES[value.toLowerCase()];
			}
			setConfigurationProperty(id, 'Billing_Frequency__c', val);
		}
		this.setBillingFrequency = setBillingFrequency;

		function setContractTerm(id, value) {
			var val = null;
			if (value != null) {
				val = parseInt(value, 10);
			}
			setConfigurationProperty(id, 'Contract_Term__c', val);
		}
		this.setContractTerm = setContractTerm;

		function setContractTermPeriod(id, value) {
			var val = null;
			if (value != null) {
				val = parseInt(value, 10);
				if (!val && val !== 0) val = PERIODS[value.toLowerCase()];
			}
			setConfigurationProperty(id, 'Contract_Term_Period__c', val);
		}
		this.setContractTermPeriod = setContractTermPeriod;

		function getConfigurationWrapper(id) {
			var key = endsWith(id, ':') ? id.substring(0, id.length-1) : id,
				wrapper = Service.config[key];
			if (!wrapper) {
				Log.error('Configuration not found for reference ' + key);
				return;
			}
			if (!wrapper.config) {
				Log.error('Reference is not a Configuration', key, wrapper);
				return;
			}
			return wrapper;
		}
		this.getConfigurationWrapper = getConfigurationWrapper;

		function getConfigurationProperty(id, prop) {
			var wrapper = getConfigurationWrapper(id),
				propLc = prop ? prop.toLowerCase() : '',
				accessor = CONFIG_PROPERTY_ACCESSORS[propLc],
				value;

			if (wrapper) {
				value = accessor ? accessor(wrapper) : wrapper.config[prop];
				if (value === undefined) {
					if (!accessor && !(prop in wrapper.config)) {
						Log.error('Could not find property ' + prop + ' for configuration ' + id);
					}
				}
				return value;
			}
		}
		this.getConfigurationProperty = getConfigurationProperty;

		function setConfigurationProperty(id, prop, value) {
			var wrapper = getConfigurationWrapper(id);
			if (wrapper) {
				if (value && value.isCallback) {
					value.applyValue = function(data) {
						var currentVal = wrapper.config[prop];
						var val = data[value.fieldName];
						if (!val) val = '';
						if (val != currentVal) {
							setConfigurationProperty(id, prop, val);
						}
					};
				} else {
					if (!prop) {
						return;
					}

					var accessor = CONFIG_PROPERTY_ACCESSORS[prop.toLowerCase()];

					if (wrapper && accessor) {
						accessor(wrapper, value);
					}
				}
			}
		}
		this.setConfigurationProperty = setConfigurationProperty;

		function reset() {
			var wrapper,
				definition,
				config = Service.config;

			for (var ref in config) {
				wrapper = config[ref];
				if (wrapper.attr) {
					definition = wrapper.definition || Service.getProductIndex().all[wrapper.definitionId];
					if (!definition) {
						CS.Log.error('Definition not found for attribute ref', ref);
						continue;
					}
					CS.binding.update(wrapper.reference, {
						active: true,
						readOnly: false,
						lineItem: definition[prefix + 'Is_Line_Item__c'],
						recurring: definition[prefix + 'Recurring__c'],
						//lineItemDescription: definition[prefix + 'Line_Item_Description__c'],
						required: definition[prefix + 'Required__c']
					});
				} else if (wrapper.config) {
					setConfigurationProperty(wrapper.reference, 'status', 'Valid');
					setConfigurationProperty(wrapper.reference, 'validationmessage');
				}
				clearInfo();
				clearWarning();
			}
		}
		this.reset = reset;

	}).call(CS);

	return CS;
});
/*
	CS DATA BINDER
*/

define('src/csdatabinder',[
	'./csbase',
	'./csutil'
], function(CS, Util) {
	var DEFAULT_HANDLER_KEY = 'default';

	var Log = CS.Log,
		defaultHandler = {
			getInstance: function() {
				return this;
			},
			init: function(binding) {
				Log.debug('Registered default handler for ' + binding.wrapper.reference);
			},
			update: function(binding, properties, triggerEvent) {
				this.updateAttribute(binding.wrapper, properties);
			},
			updateUI: function() {
			},
			updateAttribute: function(wrapper, properties) {
				DataBinder.applyProperties(wrapper, properties);
			}
		},
		groupSelectors = [
			'[data-cs-control]', '[data-cs-label]', '[data-cs-required]'
		],
		prefix = Util.configuratorPrefix || '',
		mutableProperties = {
			active: prefix + 'is_active__c',
			displayValue: prefix + 'Display_Value__c',
			lineItem: prefix + 'Is_Line_Item__c',
			lineItemDescription: prefix + 'Line_Item_Description__c',
			price: prefix + 'Price__c',
			readOnly: prefix + 'Is_Read_Only__c',
			recurring: prefix + 'Recurring__c',
			required: prefix + 'Is_Required__c',
			value: prefix + 'Value__c'
		},
		nextBindingId = 1,
		wrapperProperties = {
			validationError: 'validationError',
			validationMessage: 'validationMessage'
		};

	var DataBinder = {
		handlers: {
			'default': defaultHandler
		},

		registerGroupSelector: function(selector) {
			groupSelectors.push(selector);
		},

		getGroupSelectors: function() {
			return groupSelectors;
		},

		registerHandler: function(name, handler, overwrite) {
			if (!overwrite && this.handlers[name]) {
				Log.warn('Handler already registered for ' + name + ' and overwrite not forced - handler rejected', handler);
				return;
			}

			this.handlers[name] = wrapHandler(handler);

			function wrapHandler(delegate) {

				return {
					getInstance: function(binding) {
						var instance = {
							init: function(binding) {
								var populateLabels = true;

								if (jQuery(binding.element).size() === 0) {
									binding.offScreen = true;
									populateLabels = false;
									Log.debug('Binding off screen attribute ', binding.wrapper.reference);
								}

								if (delegate) {
									if (!binding.offScreen && delegate.willPopulateLabels && delegateWillPopulateLabels()) {
										populateLabels = delegate.willPopulateLabels(binding);
									}

									jQuery(binding.element).keypress(function(e) {
										if (e.which === 13) {
											e.preventDefault();
											e.stopPropagation();
											e.target.blur();
										}
									});

									if (delegate.onChange) {
										jQuery(binding.element).change((function(binding, ref) {
											return function(e) {
												delegate.onChange(binding, ref, e);
											};
										}(binding, binding.wrapper.reference)));
									} else {
										jQuery(binding.element).change((function(binding, ref) {
											return function(e) {
												binding.dataBinder.update(ref, {value: e.target.value});
											};
										}(binding, binding.wrapper.reference)));
									}

									if (delegate.init) {
										delegate.init(binding);
									}
								}

								if (populateLabels) {
									CS.UI.Effects.populateLabels(binding);
								}

								if (!binding.offScreen) {
									this.updateUI(binding, false);
								}

								if (Log.isDebugEnabled()) {
									Log.debug('Registered ', (delegate ? delegate.name : 'default'), ' handler for ', binding.wrapper.reference);
								}
							},

							getName: function() {
								return delegate ? delegate.name : 'default';
							},

							update: function(binding, properties, triggerEvent) {
								if (CS.binding.isMonitored(binding.wrapper.reference)) {
									throw 'Binding ' + binding.wrapper.reference + ' monitoring debug breakpoint';
								}
								if (delegate && delegate.update) {
									delegate.update(binding, properties, triggerEvent);
								}
								this.updateAttribute(binding.wrapper, properties);
								if (!binding.offScreen) {
									this.updateUI(binding, triggerEvent);
								}
							},

							updateAttribute: function(wrapper, properties) {
								if (delegate && delegate.updateAttribute) {
									delegate.updateAttribute(wrapper, properties);
								} else {
									DataBinder.applyProperties(wrapper, properties);
								}
							},

							updateUI: function(binding, triggerEvent) {
								if (delegate && delegate.updateUI) {
									delegate.updateUI(binding, triggerEvent);
								}
							}
						};
						instance.init(binding);
						return instance;
					}
				};
			}
		},

		prepareScreenTemplates: function(index) {
			var allScreens = jQuery('script[data-cs-ref]'),
				screenTemplatesByReference = {};

			jQuery.each(allScreens, function(i, it) {
				var tpl = jQuery(it),
					ref = tpl.attr('data-cs-ref'),
					screenDef = index.screensByReference[ref];

				if (screenDef === undefined) {
					Log.info('No screen found in model for reference ' + ref + ', skipping');
					return;
				}

				screenTemplatesByReference[ref] = it;
				if (Log.isDebugEnabled()) Log.debug('Binding template ' + ref, it);
			});

			return screenTemplatesByReference;
		},

		buildScreen: function(screenRef, wrapper, screens) {
			var tpl = screens[screenRef],
				configRef = wrapper.reference === '' ? '' : wrapper.reference + ':',
				html;

			if (tpl === undefined) {
				Log.warn('Could not find screen template with reference: ' + screenRef, screens);
				return;
			}

			html = tpl.innerHTML.replace(/%idx%/g, '0').replace(/%ctx%/g, configRef);

			return html;
		},

		bind: function(data, index, screens) {
			var bindingElements = {},
				allGroups = [],
				bindingsByAttrReference = {},
				bindingGroupsByAttrReference = {},
				instance = CS.binding = this.newInstance(data, index, {
					bindingsByAttrReference: bindingsByAttrReference,
					bindingGroupsByAttrReference: bindingGroupsByAttrReference
				}),
				self = this;

			if (!jQuery.isArray(screens)) {
				screens = [screens];
			}

			jQuery.each(screens, function(i, it) {
				jQuery.each(jQuery(it).find('[data-cs-binding]'), function(i2, it2) {
					bindingElements[it2.getAttribute('data-cs-binding')] = it2;
				});
			});

			jQuery.each(screens, function(i, it) {
				jQuery.each(jQuery(it).find(self.getGroupSelectors().join(',')), function(i2, it2) {
					allGroups.push(it2);
				});
			});

			jQuery.each(data, function(ref, wrapper) {
				var attrDefinition,
					bindings = bindingsByAttrReference[ref],
					j = jQuery(bindingElements[ref]);

				if (!wrapper.attr) {
					// skip Configurations
					return;
				}

				if (typeof(wrapper.definition) === 'object') {
					attrDefinition = wrapper.definition;
				} else {
					attrDefinition = index.find('all', wrapper.definitionId);
				}

				if (!attrDefinition) {
					Log.warn('No definition found for attribute ' + ref, wrapper);
				}

				wrapper.definition = attrDefinition;

				if (!bindings) {
					bindings = bindingsByAttrReference[ref] = [];
				}

				bindings.push({id: ++nextBindingId, wrapper: wrapper, element: j, offScreen: j.size() === 0, uiState: {}, dataBinder: instance});
			});

			jQuery.each(groupSelectors, function(i, it) {
				var domAttr = it.substring(1, it.length-1);

				jQuery.each(jQuery(allGroups).filter(it), function(i2, it2) {
					var field = jQuery(it2),
						ref = field.attr(domAttr),
						wrapper = data[ref],
						groups = bindingGroupsByAttrReference[ref];

					if (!groups) groups = bindingGroupsByAttrReference[ref] = {};
					var group = groups[it];
					if (!group) group = groups[it] = [];

					var binding = {wrapper: wrapper};
					binding[it] = it2;
					group.push(binding);
				});
			});

			var initHandler = function(i, it) {
				var handler,
					wrapper = it.wrapper,
					key = wrapper.displayInfo ? wrapper.displayInfo : '';

				handler = DataBinder.handlers[key];

				if (handler === undefined) {
					if (wrapper.attr[prefix + 'Hidden__c']) {
						handler = DataBinder.handlers[DEFAULT_HANDLER_KEY];
					} else {
						Log.debug('No handler available for ', ref, ' (', key, '), using default handler');
						handler = DataBinder.handlers[DEFAULT_HANDLER_KEY];
					}
				}

				it.handler = handler.getInstance(it);
			};

			Log.debug('Bindings', bindingsByAttrReference);

			jQuery.each(bindingsByAttrReference, function(k, v) {
				jQuery.each(v, initHandler);
			});

			return instance;
		},

		newInstance: function(data, index, uiElements) {
			var eventHandlers = {
					beforeupdate: [],
					afterupdate: []
				},
				monitoredAttributes = {};

			return {
				currentEvent: undefined,

				getAttributeWrapper: function(ref) {
					return data[ref];
				},

				getBindings: function(ref) {
					var bindings;
					try {
						bindings = uiElements.bindingsByAttrReference[ref];
					} catch (e) {
						Log.warn('Could not get bindings for reference', ref);
					}
					return bindings ? bindings : [];
				},

				getControls: function(ref) {
					var controls;
					try {
						controls = uiElements.bindingGroupsByAttrReference[ref]['[data-cs-control]'];
					} catch (e) {
						Log.debug('Could not get controls for reference', ref);
					}
					return controls ? controls : [];
				},

				getIndex: function() {
					return index;
				},

				getLabels: function(ref) {
					var elements;
					try {
						elements = uiElements.bindingGroupsByAttrReference[ref]['[data-cs-label]'];
					} catch (e) {
						Log.debug(e);
					}
					return elements ? elements : [];
				},

				getRequiredIndicators: function(ref) {
					var indicators,
						bindingGroup = uiElements.bindingGroupsByAttrReference[ref];

					if (bindingGroup) {
						indicators = bindingGroup['[data-cs-required]'];
					}
					return indicators ? indicators : [];
				},

				isMonitored: function isMonitored(ref) {
					return monitoredAttributes[ref];
				},

				monitor: function monitor(ref, bool) {
					var refs,
						on = bool === undefined ? true : bool;

					if (jQuery.isArray(ref)) {
						refs = ref;
					} else  {
						refs = [ref];
					}
					for (var i = refs.length; i--; ) {
						monitoredAttributes[refs[i]] = on;
					}
				},

				on: function(eventName, handler) {
					if (typeof(eventName) !== 'string') {
						return Log.warn('Invalid event name - ignoring', eventName);
					}

					var handlers = eventHandlers[eventName.toLowerCase()];
					if (!handlers) {
						return Log.warn('Event name not understood', eventName);
					}

					handlers.push(handler);
				},

				unbind: function(eventName) {
					if (typeof(eventName) !== 'string') {
						return Log.warn('Invalid event name - ignoring', eventName);
					}

					var handlers = eventHandlers[eventName.toLowerCase()];
					if (!handlers) {
						return Log.warn('Event name not understood', eventName);
					}

					eventHandlers[eventName.toLowerCase()] = [];
				},

				update: function(ref, properties, event) {
					var wrapper = data[ref],
						bindings = uiElements.bindingsByAttrReference[ref],
						isUpdate = false,
						oldVal = undefined,
						wasUpdate = false,
						beforeUpdate = eventHandlers.beforeupdate,
						afterUpdate = eventHandlers.afterupdate,
						i;

					Log.debug('Update', ref, properties, event, bindings);

					if (!wrapper) {
						Log.warn('Attribute: ' + ref + ' not found');
						return;
					}

					if (!bindings) {
						Log.warn('Bindings for attribute: ' + ref + ' not found');
						return;
					}

					this.currentEvent = event;
					oldVal = wrapper.attr[prefix + 'Value__c'];
					isUpdate = ('value' in properties && properties.value !== oldVal);

					if (isUpdate) {
						i = beforeUpdate.length;
						while (i--) {
							try {
								beforeUpdate[i](ref, properties, event);
							} catch(e) {
								Log.error('Error in before update handler', e);
							}
						}
					}

					jQuery.each(bindings, function(i, it) {
						if (it.handler) {
							it.handler.update(it, properties);
						} else {
							Log.debug('No handler, skipping', it);
						}
					});

					wasUpdate = isUpdate && (oldVal != wrapper.attr[prefix + 'Value__c']);

					if (wasUpdate) {
						i = afterUpdate.length;
						while (i--) {
							try {
								afterUpdate[i](ref, properties, event);
							} catch(e) {
								Log.error('Error in after update handler', e);
							}
						}
					}
				}
			};
		},

		applyProperties: function(wrapper, props) {
			var attr = wrapper.attr,
				prop,
				attrProp;
			for (prop in props) {
				attrProp = mutableProperties[prop];
				if (attrProp) {
					attr[attrProp] = props[prop];
				} else {
					attrProp = wrapperProperties[prop];
					if (attrProp) {
						wrapper[attrProp] = props[prop];
					}
				}
			}
		}
	};

	return DataBinder;
});

/**
 * CS OG
 * ObjectGraph processing for Javascript
 */
define('src/csog',[
	'./csbase',
	'./csutil'
], function(CS, Util) {
	var Log = CS.Log,
		configuratorPrefix = Util.configuratorPrefix || '',
		offlinePrefix = Util.offlinePrefix || '',
		OG_REFERENCES_IDX = 2,
		OG_OBJECTS_START_IDX = 3,
		NULL_SELECT_OPTION = {
			"attributes" : {
				"type" : configuratorPrefix + "Select_Option__c"
			},
			"Name" : "--None--"
		};
	NULL_SELECT_OPTION[configuratorPrefix + "Value__c"] = "--None--";

	function buildIndex(strategyIndex) {
		var index = {
			find: function(category, key) {
				if (!this[category]) {
					//Log.warn('Could not find category in product index:', category, key);
					return undefined;
				}
				if (!this[category][key]) {
					//Log.warn('Could not find key in category of product index:', category, key);
					return undefined;
				}
				return this[category][key];
			}
		};

		for (var item in strategyIndex) {
			if (Log.isDebugEnabled() && index.item) Log.debug('Index function ' + item + ' overridden');
			index[item] = strategyIndex[item];
		}

		return index;
	}

	var productIndexStrategy = {
		getInstance: function() {
			var index = {
				all: {},
				attributeDefsByProduct: {},
				attributeDefsByScreen: {},
				attributeFieldDefsByAttributeDef: {},
				availableProductsByAttributeDef: {},
				categoriesByReference: {},
				lookupQueriesByName: {},
				productsById: {},
				productsByReference: {},
				screensByProduct: {},
				screensByReference: {},
				selectOptionsByAttribute: {},
				selectOptionsMapByAttribute: {}
			};

			var indexers = {
				Default: function(o) {
					var msg = Util.validateProperties(o, o.attributes.type, ['Id']);
					if (msg) {
						return Log.info(msg, o);
					}
					index.all[o.Id] = o;
				},

				Attribute_Definition__c: function(o) {
					var msg = Util.validateProperties(o, 'Attribute Definition', ['Id', configuratorPrefix + 'Product_Definition__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					var shortId = o[configuratorPrefix + 'Product_Definition__c'].substring(0, 15),
						longId = o[configuratorPrefix + 'Product_Definition__c'],
						attDefs1 = index.attributeDefsByProduct[longId],
						attDefs2 = index.attributeDefsByProduct[shortId];
					if (!attDefs1) {
						attDefs1 = index.attributeDefsByProduct[longId] = {};
						attDefs2 = index.attributeDefsByProduct[shortId] = {};
					}
					attDefs1[o.Id] = o;
					attDefs2[o.Id] = o;
					var screenId = o[configuratorPrefix + 'Configuration_Screen__c'],
						screen = index.attributeDefsByScreen[screenId];

					if (!screen) {
						screen = index.attributeDefsByScreen[screenId] = {};
					}
					screen[o.Id] = o;

				},

				Attribute_Field_Definition__c: function(o) {
					var msg = Util.validateProperties(o, 'Attribute Field Definition', ['Id', configuratorPrefix + 'Attribute_Definition__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					var shortId = o[configuratorPrefix + 'Attribute_Definition__c'].substring(0, 15),
						longId = o[configuratorPrefix + 'Attribute_Definition__c'],
						attFieldDefs1 = index.attributeFieldDefsByAttributeDef[longId],
						attFieldDefs2 = index.attributeFieldDefsByAttributeDef[shortId];
					if (!attFieldDefs1) {
						attFieldDefs1 = index.attributeFieldDefsByAttributeDef[longId] = {};
						attFieldDefs2 = index.attributeFieldDefsByAttributeDef[shortId] = {};
					}
					attFieldDefs1[o.Id] = o;
					attFieldDefs2[o.Id] = o;
				},

				Available_Product_Option__c: function(o) {
					var msg = Util.validateProperties(o, 'Available Product Option', ['Id', configuratorPrefix + 'Attribute_Definition__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					var products = index.availableProductsByAttributeDef[o[configuratorPrefix + 'Attribute_Definition__c']];
					if (!products) {
						products = index.availableProductsByAttributeDef[o[configuratorPrefix + 'Attribute_Definition__c']] = [];
					}
					products.push(o);
					/* Sequence not defined on Available_Product_Option__c yet!
					products.sort(function(a,b) {
						return a[configuratorPrefix + 'Sequence__c'] > b[configuratorPrefix + 'Sequence__c'] ? 1 : a[configuratorPrefix + 'Sequence__c'] === b[configuratorPrefix + 'Sequence__c'] ? 0 : -1;
					});*/
				},

				Configuration_Screen__c: function(o) {
					var msg = Util.validateProperties(o, 'Configuration Screen', ['Id', configuratorPrefix + 'Product_Definition__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					var shortId = o[configuratorPrefix + 'Product_Definition__c'].substring(0, 15),
						screens1 = index.screensByProduct[shortId],
						screens2 = index.screensByProduct[o[configuratorPrefix + 'Product_Definition__c']];
					if (!screens1) {
						screens1 = index.screensByProduct[shortId] = [];
						screens2 = index.screensByProduct[o[configuratorPrefix + 'Product_Definition__c']] = [];
					}
					screens1.push(o);
					screens2.push(o);
					// Inefficient! This should be done by OG server side if possible
					screens1.sort(function(a,b) {
						return a[configuratorPrefix + 'Index__c'] > b[configuratorPrefix + 'Index__c'] ? 1 : a[configuratorPrefix + 'Index__c'] === b[configuratorPrefix + 'Index__c'] ? 0 : -1;
					});
					screens2.sort(function(a,b) {
						return a[configuratorPrefix + 'Index__c'] > b[configuratorPrefix + 'Index__c'] ? 1 : a[configuratorPrefix + 'Index__c'] === b[configuratorPrefix + 'Index__c'] ? 0 : -1;
					});
				},

				Lookup_Query__c: function(o) {
					var msg = Util.validateProperties(o, 'Lookup Query', ['Id']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					index.lookupQueriesByName['Lookup(' + o.Name + ')'] = o;
				},

				Product_Category__c: function(o) {
					var msg = Util.validateProperties(o, 'Product Category', ['Id', configuratorPrefix + 'Reference__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					index.categoriesByReference[o.cscfga__Reference__c] = o;
				},

				Product_Definition__c: function(o) {
					var msg = Util.validateProperties(o, 'Product Definition', ['Id', offlinePrefix + 'Reference__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = o;
					// index by both 18- and 15-char ID
					index.productsById[o.Id] = o;
					index.productsById[o.Id.substring(0, 15)] = o;
					index.productsByReference[o[offlinePrefix + 'Reference__c']] = o;
				},

				Select_Option__c: function(o) {
					var msg = Util.validateProperties(o, 'Select Option', ['Name', configuratorPrefix + 'Attribute_Definition__c', configuratorPrefix + 'Value__c']);
					if (msg) {
						return Log.info(msg, o);
					}

					index.all[o.Id] = 0;
					var options = index.selectOptionsByAttribute[o[configuratorPrefix + 'Attribute_Definition__c']],
						optionsMap = index.selectOptionsMapByAttribute[o[configuratorPrefix + 'Attribute_Definition__c']];
					if (!options) {
						options = index.selectOptionsByAttribute[o[configuratorPrefix + 'Attribute_Definition__c']] = [];
						optionsMap = index.selectOptionsMapByAttribute[o[configuratorPrefix + 'Attribute_Definition__c']] = {};
					}
					options.push(o);
					optionsMap[o.Name] = o;
					// This should be done by OG server side if possible
					options.sort(function(a,b) {
						return a[configuratorPrefix + 'Sequence__c'] > b[configuratorPrefix + 'Sequence__c'] ? 1 : a[configuratorPrefix + 'Sequence__c'] === b[configuratorPrefix + 'Sequence__c'] ? 0 : -1;
					});
				}
			};

			return {
				initIndex: function() {
					return index;
				},

				indexObject: function(o) {
					if (!o.attributes || !o.attributes.type) {
						Log.warn('Malformed OG data - no type', o);
						return;
					}
					var index = indexers[o.attributes.type] || indexers[o.attributes.type.match(/(?:.+__)?(.+__c)/)[1]]; // test with and without prefix
					if (!index) {
						Log.warn('No indexer found for type ' + o.attributes.type + ', using Default', indexers);
						index = indexers.Default;
					}
					index(o);
					Log.debug('  ' + o.Id, o);
				},

				postProcessIndex: function() {
					var id;

					for (id in index.selectOptionsByAttribute) {
						var attDef = index.all[id];
						if (attDef && attDef[configuratorPrefix + 'Enable_null_option__c']) {
							var options = index.selectOptionsByAttribute[id];
							options.unshift(NULL_SELECT_OPTION);
						}
					}

					for (id in index.screensByProduct) {
						var product = index.all[id],
							screens = index.screensByProduct[id],
							i = screens.length;

						while (product && screens && i--) {
							var screen = screens[i],
								ref = screen.Name || screen.Id || null;
							var reference = product[offlinePrefix + 'Reference__c'] + ':' + Util.generateId(ref);
							screen._reference = reference;
							index.screensByReference[reference] = screen;
						}
					}
				}
			};
		}
	};

	var OG = {
		indexProducts: function(json) {
			return this.index(json, productIndexStrategy.getInstance());
		},

		index: function(json, strategy) {
			var types = json[0],
				index = buildIndex(strategy.initIndex());

			configuratorPrefix = Util.configuratorPrefix || '';
			offlinePrefix = Util.offlinePrefix || '';

			if (types.length < 1) {
				Log.warn('No types in ObjectGraph');
				return index;
			}

			Log.debug('Indexing ObjectGraph data...');

			for (var i = types.length; i--; ) {
				var offset = OG_OBJECTS_START_IDX + i;
				var os = json[offset];

				if (!os) continue; // no objects of type present

				if (Log.isDebugEnabled()) Log.debug(os[0].attributes.type + ': ' + os.length + ' object' + (os.length == 1 ? '' : 's'));

				for (var j = os.length; j--; ) {
					var o = os[j];
					if (o) {
						strategy.indexObject(os[j]);
					}
				}
			}

			// Resolve circular references
			var circularRefs = json[OG_REFERENCES_IDX];
			for (var i = 0; i < circularRefs.length; i++) {
				var ref = circularRefs[i];
				if (ref) {
					var o = index.all[ref.objectID];
					o[ref.referenceField] = ref.referenceValue;
				}
			}

			strategy.postProcessIndex();

			return index;
		}

	};

	return OG;
});
define('src/csrules',[
	'./csbase',
	'./csutil'
], function(CS, Util) {
	var Log = CS.Log;

	var rules = {},
		calcs = {},
		lockedFields = {},
		rulesSuspended = false,
		indicatorTimer;

	function evaluateAllRules(msg) {
		Log.info('Rule execution invoked', msg, rules, calcs);
		CS.executeOnLookupQueriesDone(executeRules, 'executeRules');
	}

	function executeRules() {
		if (rulesSuspended) {
			return;
		}

		var passes = 0,
			passRequired = true,
			startTime = new Date().getTime(),
			endTime;

		if (CS.indicator) {
			Log.warn('Starting indicator for rules');
			CS.indicator.start('#indicatorContainer');
		}

		CS.UI.suspendUpdates();
		CS.reset();

		while (++passes < 3 && passRequired) {
			unlockAttributes();
			CS.log('>>>>> Rule evaluation: pass ' + passes);
			rulesSuspended = true;
			performCalculations();
			rulesSuspended = false;
			runFunctions(rules);
			passRequired = !Util.isEmpty(lockedFields);
		}
		unlockAttributes();

		endTime = new Date().getTime();
		CS.log('*** Completed rule evaluation: ' + passes + ' passes in ' + (endTime - startTime) + ' ms ***');

		var validation = CS.Service.getLastScreenValidation();
		if (validation && !validation.isValid) {
			CS.markConfigurationInvalid('The previous screen is incomplete or has an invalid configuration');			
		}
		
		CS.UI.resumeUpdates();
		// Not using executeOnLookupQueriesDone to join across multiple runs of rules with a single timer

		function clearIndicator() {
			if (CS.lookupQueriesAreQueued()) {
				CS.Log.info('Waiting to clear rules indicator');
				indicatorTImer = setTimeout(clearIndicator, 150);
			} else {
				CS.Log.info('Stopping indicator for rules');
				CS.indicator.stop();
			}
		}

		indicatorTimer = setTimeout(clearIndicator, 150);
	}

	function runFunctions(funcs) {
		for (var f in funcs) {
			try {
				funcs[f]();
			} catch (e) {
				Log.warn('Error running functions for ', f, e.message, e);
			}
		}
	}

	function performCalculations() {
		runFunctions(calcs);
	}

	function fireChange(wrapper) {
		var reference = wrapper.reference;
		if (lockedFields[reference]) {
			Log.info('Field locked, no further changes', reference);
		} else {
			Log.debug('Field changed: ' + reference);
			lockedFields[reference] = true;
		}
	}

	function unlockAttributes() {
		lockedFields = {};
	}
	this.unlockAttributes = unlockAttributes;

	return {
		calcs: calcs,
		evaluateAllRules: evaluateAllRules,
		fireChange: fireChange,
		performCalculations: performCalculations,
		rules: rules,

		hasRules: function(context) {
			return false;
		},

		addRules: function(ref, rulesHtml) {
			//var ref = Util.generateId(context.productDef.cfgoffline__Reference__c + '_' + context.index),
			var funcs = eval(rulesHtml);

			if (funcs && funcs.executeRules) {
				this.rules[ref] = funcs.executeRules;
			}

			if (funcs && funcs.performCalculations) {
				this.calcs[ref] = funcs.performCalculations;
			}
		},

		removeRules: function removeRules(ref) {
			if (this.rules[ref]) {
				delete this.rules[ref];
			}
			if (this.calcs[ref]) {
				delete this.calcs[ref];
			}
		},

		resetRules: function() {
			for (var key in this.rules) {
				delete this.rules[key];
			}
			for (key in this.calcs) {
				delete this.calcs[key];
			}
		},

		rulesSuspended: function() {
			return rulesSuspended;
		}

	};
});
/**
	@memberOf CS
	@requires Base
	@requires OG
	@requires Util
*/
define('src/csservice',[
	'./csbase',
	'./csog',
	'./csutil'
], function(CS, OG, Util) {
	var Log = CS.Log,
		prefix = Util.configuratorPrefix,
		offlinePrefix = Util.offlinePrefix,
		ROOT_REFERENCE = '',
		globalIndex = {},
		indices = {};

	function buildAttribute(def, context, selectOptions, attributeFields) {
		context = context || {};
		var wrapper = {
			"attr": {
				"attributes": {
					"type": prefix + "Attribute__c"
				}
			},
			"attributeFields": {},
			"definitionId": def.Id,
			"displayInfo": context.displayInfo || def[prefix + 'Type__c'],
			"reference": Util.generateReference(def.Name, context),
			"relatedProducts": [],
			"selectOptions": selectOptions
		};
		wrapper.attr[prefix + "Attribute_Definition__c"] = def.Id;
		wrapper.attr[prefix + 'Cascade_value__c'] = def[prefix + 'Cascade_value__c'];
		wrapper.attr[prefix + 'Display_Value__c'] = (def[prefix + 'Type__c'] === 'Calculation' ? null : def[prefix + 'Default_Value__c']);
		wrapper.attr[prefix + 'Hidden__c'] = def[prefix + 'Hidden__c'];
		wrapper.attr[prefix + 'is_active__c'] = true;
		wrapper.attr[prefix + 'Is_Line_Item__c'] = def[prefix + 'Is_Line_Item__c'];
		wrapper.attr[prefix + 'Is_Required__c'] = def[prefix + 'Required__c'];
		wrapper.attr[prefix + 'Line_Item_Sequence__c'] = def[prefix + 'Line_Item_Sequence__c'];
		wrapper.attr[prefix + 'Line_Item_Description__c'] = def[prefix + 'Line_Item_Description__c'];
		wrapper.attr.Name = def.Name;
		wrapper.attr[prefix + 'Price__c'] = def[prefix + 'Base_Price__c'] || 0;
		wrapper.attr[prefix + 'Value__c'] = (def[prefix + 'Type__c'] === 'Calculation' ? '' : def[prefix + 'Default_Value__c']);
		wrapper.attr[prefix + 'Recurring__c'] = def[prefix + 'Recurring__c'];

		if (def[prefix + 'Type__c'] === 'Select List' && def[prefix + 'Default_Value__c'] && selectOptions) {
			for (var i = 0; i < selectOptions.length; i++) {
				if (selectOptions[i] == def[prefix + 'Default_Value__c']) {
					wrapper.attr[prefix + 'Display_Value__c'] = selectOptions[i].Name;
					break;
				}
			}
		}

		_.each(attributeFields, function(a) {
			setAttributeField(wrapper, a.Name, a[prefix + 'Default_Value__c']);
		});


		return wrapper;
	}

	function buildConfig(def, reference, context) {
		var wrapper = {
			"reference" : reference,
			"config" : {
				"attributes" : {
					"type" : "Product_Configuration__c"
				}
			}
		};
		wrapper.config[prefix + 'Attribute_Name__c'] = context.attrName;
		wrapper.config[prefix + 'Billing_Frequency__c'] = def[prefix + 'Default_Billing_Frequency__c'];
		wrapper.config[prefix + 'Contract_Term__c'] = def[prefix + 'Default_Contract_Term__c'];
		wrapper.config[prefix + 'Contract_Term_Period__c'] = CS.getPeriodValueForName(def[prefix + 'Default_Contract_Term_Period__c']);
		wrapper.config[prefix + 'Description__c'] = def[prefix + 'Description__c'];
		wrapper.config[prefix + 'Index__c'] = context.index;
		wrapper.config[prefix + 'Last_Screen_Index__c'] = 0;
		wrapper.config.Name = def.Name;
		wrapper.config[prefix + 'Product_Definition__c'] = def.Id;
		wrapper.config[prefix + 'Recurrence_Frequency__c'] = def[prefix + 'Default_Frequency__c'];
		wrapper.config[prefix + 'Configuration_Status__c'] = 'Incomplete';
		wrapper.config[prefix + 'Validation_Message__c'] = '';

		return wrapper;
	}

	// Deletes all entries in the supplied config data index which are children of 'ref'
	// Does not remove 'ref' itself
	function deleteChildReferences(ref, data) {
		for (var attrRef in data) {
			if (attrRef !== ref && Util.startsWith(attrRef, ref)) {
				delete data[attrRef];
			}
		}
	}

	function error() {
		Log.error.apply(Log, arguments);
	}

	function getContext(ref, attrName, idx, parent) {
		return {ref: ref, attrName: attrName, index: (idx || 0), parent: parent};
	}

	function loadConfiguration(delegate, config, ref, data, callback) {
		jQuery.extend(config, data);
		var allConfigs = _.filter(data, function(it) { return it.config != null; }),
			allConfigsMap = {},
			synchroniser = CS.Util.callbackSynchroniser({
				success: function() {
					for (var i = 0; i < allConfigs.length; i++) {
						var cfg = allConfigs[i],
							productId = cfg.config[prefix + 'Product_Definition__c'],
							productDef = CS.Service.getProductIndex(productId).all[productId];
						loadRulesForConfig(cfg.reference, productDef);
					}
					upgradeConfigs();
					populateAttrs();
				}
			});			

		_.each(allConfigs, function(it) {
			allConfigsMap[it.config.Id] = it;
			if (it.config[prefix + 'Key__c']) {
				allConfigsMap[it.config[prefix + 'Key__c']] = it;
			}
			var defId = it.config[prefix + 'Product_Definition__c'];
			if (!CS.Service.getProductIndex(defId)) {
				synchroniser.register('Load product ' + defId, function() {
					CS.Service.loadProduct(defId, function() {
						synchroniser.register('Load Product Templates ' + defId, function() {
							delegate.loadProductTemplateHtml(defId, function() {
								if (!CS.screens) {
									CS.screens = {};
								}
								jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(CS.Service.getProductIndex(defId)));
								synchroniser.complete('Load Product Templates ' + defId);
							});
						});
						synchroniser.complete('Load product ' + defId);
					});
				});
			}
		});

		synchroniser.start();

		/**
		 * Check the product definitions for all products in the configuration and
		 * if necessary, add any new attributes which have been defined since the
		 * configuration was last modified
		 */
		function upgradeConfigs() {
			var configs = _.filter(data, function(it) { return it.config != null; });
			_.each(configs, function (wrapper) {
				var ref = wrapper.reference,
					productId = wrapper.config[prefix + 'Product_Definition__c'],
					index = CS.Service.getProductIndex(productId),
					attrDefs = index.attributeDefsByProduct[productId];

				_.each(attrDefs, function(def) {
					var attRef = CS.Util.generateReference(def[offlinePrefix + 'Reference_Name__c'], {ref: ref});
					if (!data[attRef]) {
						Log.info(attRef, ' missing from config, upgrading');
						var attWrapper = buildAttribute(def, {ref: ref}, index.selectOptionsByAttribute[def.Id], index.attributeFieldDefsByAttributeDef[def.Id]);
						data[attRef] = attWrapper;
					}
				});
			});
		}

		/**
		 * Repopulate nodes retrieved from online JSON to match offline runtime state
		 */
		function populateAttrs() {
			for (var attRef in data) {
				var wrapper = data[attRef],
					def = wrapper ? wrapper.definition : undefined,
					defId = wrapper ? wrapper.definitionId : undefined,
					confNode = data[CS.Util.getAnchorReference(CS.Util.getParentReference(attRef))],
					productId = confNode ? confNode.config[prefix + 'Product_Definition__c'] : undefined,
					productIndex = productId ? CS.Service.getProductIndex(productId) : undefined,
					aType;

				if (!wrapper.attr) {
					continue;
				}

				if (!productIndex) {
					CS.Log.error('No product model found for id ', productId, attRef);
					continue;
				}

				if (!defId) {
					CS.Log.error('Malformed Attribute Wrapper - no definition Id. Attribute Definition may have been removed from product since this configuration was made. The attribute has been removed from this configuration.', wrapper);
					delete config[attRef];
					continue;
				}

				if (!def) {
					def = productIndex.all[defId];
					if (!def) {
						Log.error('Could not find definition for attribute: ', wrapper);
						continue;
					}
					wrapper.definition = def;
				}

				aType = def[prefix + 'Type__c'];

				if (aType === 'Lookup' && wrapper.lookupRecord) {
					CS.lookupRecords[wrapper.attr[prefix + 'Value__c']] = wrapper.lookupRecord;
				} else if (aType === 'Select List') {
					var selectOptions = productIndex.find('selectOptionsByAttribute', defId);
					if (selectOptions) {
						wrapper.selectOptions =selectOptions;
						for (var i = 0; i < selectOptions.length; i++) {
							if (selectOptions[i] == def[prefix + 'Value__c']) {
								wrapper.attr[prefix + 'Display_Value__c'] = selectOptions[i].Name;
								break;
							}
						}
					}
				} else if (aType === 'Related Product') {
					if (!wrapper.parent) {
						var parentRef = Util.getParentReference(wrapper.reference),
							parent = stripConfig(data[parentRef]);

						wrapper.parent = parent;
					}

					if (wrapper.relatedProductIds) {
						if (!wrapper.relatedProducts) {
							wrapper.relatedProducts = [];
						}
						_.each(wrapper.relatedProductIds, function(it) {
							var config = allConfigsMap[it];
							if (config) {
								wrapper.relatedProducts.push(stripConfig(config));
							}
						});
					}
				}

				if (typeof(wrapper.attr[prefix + 'Value__c']) == 'undefined') {
					wrapper.attr[prefix + 'Value__c'] = wrapper.definition[prefix + 'Default_Value__c'];
				}

				for (var f in wrapper.attributeFields) {
					var field = wrapper.attributeFields[f];
					if (typeof(field[prefix + 'Value__c']) == 'undefined') {
						field[prefix + 'Value__c'] = '';
					}
				}
			}

			callback();
		}
	}

	/**
	 * Strip config node for reference use (config only, no related products / circular refs)
	 */
	function stripConfig(config) {
		var stripped = {
			config: config.config,
			reference: config.reference,
			parent: config.parent,
			screens: config.screens
		};
		return stripped;
	}

	function loadRulesForConfig(reference, productDef) {
		if (!CS.Rules.hasRules(reference)) {
			var tpl = jQuery('#' + Util.generateId(productDef[Util.offlinePrefix + 'Reference__c']) + '__rules'),
				rules,
				idx = 0; // this will be for 'leaf' Attributes which presently will always be index 0 (this will change if attribute arrays are introduced using the leaf node index)

			if (tpl.size() === 0) {
				Log.warn('Could not find rules template with reference: ' + productDef[Util.offlinePrefix + 'Reference__c']);
			} else {
				var ref = reference ? reference + ':' : '';
				rules = tpl.get(0).innerHTML.replace(/%idx%/g, idx).replace(/%ctx%/g, ref);
				CS.Rules.addRules(reference, rules);
			}
		}					
	}

	function checkFrequencyVal(val) {
		var num = parseInt(val);
		if (!isNaN(num)) {
			return num;
		} else {
			return CS.getFrequencyValueForName(val);
		}
	}

	function persistConfiguration(delegate, rootConfig, basketSpec, callback, error) {
		var attrs = [],
			attrMap = {},
			attrFields = [],
			data,
			config,
			configMap = {},
			configs = [],
			basket = {
				Name: 'New Basket',
				cscfga__Basket_Status__c: 'Valid',
				cscfga__Total_Price__c: 0
			},
			parentMap = {};
				 
		for (var p in basketSpec) {
			var v = basketSpec[p];
			if (v) {
				basket[p] = v;
			}
		}
		// pick out all configs and assign keys
		_.each(rootConfig, function(it) {
			if (it.config) {
				var c = it.config,
					m = it.reference.match(/(.+_)(\d+)$/),
					configRef = m ? m[1] + '0' : undefined,
					attName = configRef ? rootConfig[configRef].attr.Name : undefined,
					theConf = {
						Id: c.Id,
						Name: c.cscfga__Description__c,
						cscfga__Attribute_Name__c: attName,
						cscfga__Billing_Frequency__c: checkFrequencyVal(c.cscfga__Billing_Frequency__c),
						cscfga__Configuration_Status__c: c.cscfga__Configuration_Status__c,
						cscfga__Contract_Term_Period__c: c.cscfga__Contract_Term_Period__c,
						cscfga__Description__c: c.cscfga__Description__c,
						cscfga__Index__c : c.cscfga__Index__c,
						cscfga__Key__c: c.cscfga__Key__c ? c.cscfga__Key__c : (c.cscfga__Key__c = CS.Util.generateGUID()),
						cscfga__Product_Definition__c: c.cscfga__Product_Definition__c,
						cscfga__Recurrence_Frequency__c : checkFrequencyVal(c.cscfga__Recurrence_Frequency__c),
						cscfga__Unit_Price__c: c.cscfga__One_Off_Charge__c,
					};
                    if (c.cscfga__Configuration_Status__c !== 'Valid') {
                        basket[prefix + 'Basket_Status__c'] = 'Incomplete';
                    }
					configMap[it.reference] = theConf;
					parentMap[theConf[prefix + 'Key__c']] = CS.Util.getParentReference(configRef);
					configs.push(theConf);
			}
		});

		// link parent/child configurations via external ID cscfga__Key__c
		var rootKey = configMap[''].cscfga__Key__c;
		_.each(configMap, function(v, k) {
			if (k !== '') {
				var parentRef = parentMap[v.cscfga__Key__c],
					parentConfig = configMap[parentRef];
				v.cscfga__Parent_Configuration__r = {
					cscfga__Key__c: parentConfig.cscfga__Key__c
				};
				v.cscfga__Root_Configuration__r = {
					cscfga__Key__c: rootKey
				};
			}
		});

		// pick out attributes and link to configs
		_.each(rootConfig, function(w) {
				var a = w.attr,
					parentRef = CS.Util.getParentReference(w.reference),
					parentWrapper = CS.getAttributeWrapper(parentRef),
					productId = parentWrapper && parentWrapper.config ? parentWrapper.config.cscfga__Product_Definition__c : undefined,
					productIndex = CS.Service.getProductIndex(productId),
					definition = productIndex.all[w.definitionId],
					idx = w.reference.lastIndexOf(':'),
					configRef = idx > 0 ? w.reference.substring(0, idx) : '',
					config = configMap[configRef];

				if (a) {
					if (!definition) {
						CS.Log.warn('Attribute without definition - removing', w.reference);
						delete rootConfig[w.reference];
						return;
					}

					if (definition.cscfga__Type__c === 'Related Product') {
						var val = _.map(w.relatedProducts, function (it) {
							var config = configMap[it.reference];
							return 	config.cscfga__Key__c;
						}).join(',');
						a.cscfga__Value__c = val;
					}

					if (a.cscfga__Value__c && a.cscfga__Value__c.length > 31999) {
						CS.Log.warn('Attribute has value over 32K in length:', w.reference);
						a.cscfga__Value__c = a.cscfga__Value__c.substring(0, 31999);
					}

					if (a.cscfga__Display_Value__c && a.cscfga__Display_Value__c.length > 255) {
						CS.Log.warn('Attribute has display value over 255 chars in length:', w.reference);
						a.cscfga__Display_Value__c = a.cscfga__Display_Value__c.substring(0, 255);
					}

					var attr = {
						Id: a.Id,
						Name: a.Name,
						cscfga__Product_Configuration__r: {
							cscfga__Key__c: config.cscfga__Key__c
						},
						cscfga__Display_Value__c: a.cscfga__Display_Value__c,
						cscfga__Value__c: a.cscfga__Value__c,
						cscfga__Recurring__c: a.cscfga__Recurring__c,
						cscfga__Is_Line_Item__c: a.cscfga__Is_Line_Item__c,
						cscfga__Price__c: a.cscfga__Price__c,
						cscfga__is_active__c: a.cscfga__is_active__c,
						cscfga__Key__c : a.cscfga__Key__c ? a.cscfga__Key__c : (a.cscfga__Key__c = CS.Util.generateGUID()),
						cscfga__Attribute_Definition__c: a.cscfga__Attribute_Definition__c,
						cscfga__Line_Item_Description__c: a.cscfga__Line_Item_Description__c
					};
					
					attrs.push(attr);

					_.each(w.attributeFields, function(it) {
						it.cscfga__Attribute__r = {
							cscfga__Key__c: attr.cscfga__Key__c
						};
						attrFields.push(it);
					});
				}
			}
		);

		var payload = [
			[basket],
			configs,
			attrs,
			attrFields
		];

		delegate.storeConfiguration(JSON.stringify(payload), callback, error);
	}

	function reindexChildReferences(data, ref, newIndex, newRef, isLast) {
		var anchorWrapper = data[Util.getAnchorReference(ref)],
			wrapper = data[ref];

		wrapper.reference = newRef;
		wrapper.config[prefix + 'Index__c'] = newIndex;
		if (newIndex === 0) {
			anchorWrapper.config = wrapper.config;
		} else {
			data[newRef] = wrapper;
		}

		for (var nRef in data) {
			if (nRef != ref && Util.startsWith(nRef, ref)) {
				var nRef2 = newRef + nRef.substring(ref.length);
				var node = data[nRef];
				node.reference = nRef2;
				if (node.parent) {
					var pRef = node.parent.reference;
					if (Util.startsWith(pRef, ref)) {
						node.parent.reference = newRef + pRef.substring(ref.length);
					}
				}
				data[nRef2] = node;
				delete data[nRef];
			}
		}

		if (isLast) {
			delete data[ref];
		}
	}

	function setAttributeField(wrapper, fieldName, value) {
		var attributeFields = wrapper.attributeFields,
			field;
		
		if (!attributeFields) {
			wrapper.attributeFields = attributeFields = {};
		}

		field = attributeFields[fieldName];

		if (!field) {
			attributeFields[fieldName] = field = {
				attributes: {
					"type": prefix + "Attribute_Field__c"
				},
				Name: fieldName
			};
		}

		field[prefix + 'Value__c'] = value;
		
		return field;
	}

	/** @exports Service */
	var Service = {
		/**	@static
			@public
			@param object delegate Delegate providing customised implementations of service API functions
		*/
		init: function(delegate, domSelector, rootProductId, configurationData, modelIsLoadedCallback) {
			return (function(delegate, domSelector, rootProductId, configurationData) {
				var $ = jQuery.noConflict(),
					config = {},
					containerSelector,
					currentProductId = rootProductId,
					currentScreen = {
						reference: '',
						index: 0
					},
					lastScreen,
					lastValidation,
					ancestors = [];

				/** @exports Service */
				var api = {
					/** @public
						@instance
					*/
					addRelatedProduct: function addRelatedProduct(anchorRef, productId, callback, containerSelector) {
						var products,
							productDef,
							parent = config[currentScreen.reference],
							anchorWrapper = config[anchorRef],
							attrDef = this.getAttributeDefinitionForReference(anchorRef);

						if (!attrDef) {
							return;
						}

						if (attrDef[prefix + 'Type__c'] != 'Related Product') {
							Log.error('Cannot add related product on Attribute of type ', attrDef[prefix + 'Type__c']);
							return;
						}

						if (!productId) {
							products = this.getAvailableProducts(attrRef);
							if (products.length == 1) {
								productId = products[0][prefix + 'Product_Definition__c'];
							} else {
								return this.selectProduct(anchorRef); // Not yet implemented
							}
						}

						if (config[currentScreen.reference].unsaved) {
							config[currentScreen.reference].unsaved = false;
						}

						if (CS.UI) {
							CS.UI.suspendUpdates();
						}
						var configWrapper = createConfiguration(config, anchorRef, productId, parent);
						anchorWrapper.attr[prefix + 'Display_Value__c'] = configWrapper.config.Name;
						selectConfiguration(configWrapper.reference, config);
						if (api.productHasChanged) {
							api.productHasChanged(productId, 0);
						}
						this.displayScreen(0, function() {
								if (CS.UI) {
									CS.UI.resumeUpdates();
								}
								CS.Rules.evaluateAllRules();
								callback();
							},
							containerSelector
						);
					},

					/** @public
						@instance
					*/
					cancelCurrentConfiguration: function cancelCurrentConfiguration(callback) {
						if (ancestors.length > 0) {
							var screen = ancestors[ancestors.length - 1];
							selectConfiguration(screen.reference, this.config);
							if (api.productHasChanged) {
								api.productHasChanged(currentProductId, screen.index);
							}
							this.displayScreen(screen.index, callback);
							CS.Rules.evaluateAllRules();
						}

						//TODO - implement cancel plugins
					},

					config: config,

					/** @public
						@instance
					*/
					displayScreen: function displayScreen(idx, overrideSelector, onComplete) {
						if (lastScreen && (lastScreen.reference != currentScreen.reference || lastScreen.index != idx)) {
							lastValidation = validateScreens(config, lastScreen);
						} else {
							lastValidation = undefined;
						}

						currentScreen.index = idx;

						lastScreen = {
							reference: currentScreen.reference,
							index: currentScreen.index
						};

						var ref = api.getCurrentScreenRef(),
							currentConfig = config[currentScreen.reference],
							ready = false,
							container;

						if (typeof overrideSelector === 'function') {
							onComplete = overrideSelector;
							overrideSelector = undefined;
						}

						container = jQuery(overrideSelector || containerSelector);

						if (ref) {
							var html = CS.DataBinder.buildScreen(ref, currentConfig, CS.screens),
								screen = jQuery(html);

							container.fadeOut(function(el, f) {
								return function() {
									// TODO ensure DOM elements fully released to avoid memory leaks
									doBinding();
									fadeIn(el, f);
								};
							}(container, onComplete));

							ready = true;
						}

						return ref;

						function doBinding() {
							CS.binding = CS.DataBinder.bind(config, getProductIndex(), screen, currentScreen.reference);
							jQuery.each(screen.find('[data-cs-button]'), function(i, el) {
								var it = jQuery(el),
									name = it.attr('data-cs-button'),
									action = CS.UI.Actions.find(name);

								Log.info('Wiring button ' + name + ' with action', action);

								if (action) {
									it.find('a').on('click', function() {
										return function() {
											action.action(service);
										};
									}());

									if (action.postProcess) {
										action.postProcess(it, service);
									}
								}
							});

							CS.binding.on('afterUpdate', function(ref, properties, event) {
								CS.Log.debug('After Update', ref, properties, event);
								if (!CS.rulesTimer) {
									CS.rulesTimer = window.setTimeout(function() {
										CS.Rules.evaluateAllRules('after update: ' + ref);
										CS.rulesTimer = undefined;
									}, 400);
								}
							});
						}

						function fadeIn(el, count, continuation) {
							if (typeof(count) !== 'number') {
								continuation = count;
								count = 1;
							}
							if (ready || count > 9) {
								Log.debug('Show screen:', ref);
								el.css('display', 'none').empty().html(screen).fadeIn();
								if (jQuery.mobile) {
									el.trigger('create');
								}
								if (continuation) {
									continuation();
								}
							} else {
								(function() {
									setTimeout(fadeIn(el, count + 1, continuation), 50);
								})();
							}
						}
					},

					/** @public
						@instance
					*/
					getAttributeDefinitionForReference: function getAttributeDefinitionForReference(ref) {
						var wrapper = config[ref];

						if (!wrapper || !wrapper.attr) {
							Log.error('Could not find Attribute with reference ' + ref);
							return;
						}

						attrDef = wrapper.attr.definition || getProductIndex().all[wrapper.definitionId];

						if (!attrDef) {
							Log.error('Could not find Attribute Definition for wrapper ', wrapper);
							return;
						}

						return attrDef;
					},

					/** @public
						@instance
					*/
					// To Do: Elgibility Rules
					getAvailableProducts: function getAvailableProducts(ref) {
						var attrDef = this.getAttributeDefinitionForReference(ref),
							products;

						if (!attrDef) {
							return;
						}

						products = getProductIndex().availableProductsByAttributeDef[attrDef.Id];

						if (!products || !jQuery.isArray(products)) {
							Log.info('No available products found', products);
							return [];
						}

						return products;
					},

					/** @public
						@instance
					*/
					getCurrentConfigRef: function() {
						return currentScreen.reference;
					},

					/** @public
						@instance
					*/
					getCurrentProductId: function() {
						return currentProductId;
					},

					/** @public
						@instance
					*/
					getCurrentScreen: function() {
						return this.getScreen(currentScreen.reference, currentScreen.index);
					},

					/** @public
						@instance
					*/
					getCurrentScreenIndex: function() {
						return currentScreen.index;
					},

					/** @public
						@instance
					*/
					getCurrentScreenRef: function() {
						var index = this.getProductIndex(),
							screens = index.screensByProduct[currentProductId],
							screen = (screens && screens.length > currentScreen.index) ? screens[currentScreen.index] : undefined;
						if (screen) {
							return screen._reference;
						}
						return error('Cannot find current screen: ' + currentScreen.index, screens);
					},

					getLastScreenValidation: function() {
						return lastValidation;
					},

					/** @public
						@instance
					*/
					getParentConfigRef: function() {
						return ancestors.length > 0 ? ancestors[ancestors.length-1].reference : undefined;
					},

					/** @public
						@instance
					*/
					getParentScreenIndex: function() {
						return ancestors.length > 0 ? ancestors[ancestors.length-1].index : undefined;
					},

					/** @public
						@instance
						@function
					*/
					getProductIndex: getProductIndex,

					/** @public
						@instance
						@function
					*/
					getProductLevels: function() {
						return ancestors;
					},

					/** @public
						@instance
					*/
					getScreen: function getScreen(ref, index) {
						var config = this.config[ref],
							screen;

						if (config && config.screens) {
							if (index < config.screens.length) {
								return config.screens[index];
							}
							Log.info('Screen index ' + index + ' not found in config reference: ' + ref);
						} else {
							Log.info('No config found for reference: ' + ref);
						}
					},

					/** @public
						@instance
					*/
					insertProductTemplateHtml: function insertProductTemplateHtml(html, callback) {
						var els = $(html).find('script[type="text/html"]'),
							refs = [],
							ids = [];
						els.each(function(i, it) {
							var el = $(it),
								ref = el.attr('data-cs-ref'),
								id = el.attr('id');
							if (ref) {
								refs.push('[data-cs-ref="' + ref + '"]');
							} else if (id) {
								ids.push('#' + id);
							}
						});
						$('body').find(refs.join(',')).remove();
						$('body').find(ids.join(',')).remove();
						$('body').append(els);
						setTimeout(callback, 500);
					},

					/** @public
						@instance
					*/
					isTemplateLoaded: function isTemplateLoaded(id) {
						var index = getProductIndex(id);
						for (var ref in index.screensByReference) {
							if (jQuery('script[data-cs-ref="' + ref + '"]').size() === 0) {
								return false;
							}
						}
						return true;
					},

					/** @public
						@instance
					*/
					loadProduct: function loadProduct(id, callback) {
						api.loadDefinition(id, function(model) {
							Log.info('Product Model ' + id + ' loaded, indexing...');
							var id15 = id.length > 15 ? id.substring(0, 15) : id;
							var index = OG.indexProducts(model);
							indices[id15] = index;
							for (var i in index) {
								if (!globalIndex[i]) {
									globalIndex[i] = index[i];
								} else {
									jQuery.extend(globalIndex[i], index[i]);
								}
							}
							Log.info('Product Model ' + id + ' indexed');
							if (!api.isTemplateLoaded(id)) {
								api.loadProductTemplate(id, callback);
							} else {
								callback();
							}
						});
					},

					/** @public
						@instance
					*/
					loadProductTemplate: function loadProductTemplate(id, callback) {
						api.loadProductTemplateHtml(id, function(html) {
							api.insertProductTemplateHtml(html, callback);
						});
					},

					/** @public
						@instance
					*/
					removeCurrentProduct: function removeCurrentProduct() {
						var ref = this.getCurrentConfigRef();
						if (ref === '') {
							Log.warn('Cannot remove root product');
							return;
						}
						removeRelatedProduct(ref, config);
						this.cancelCurrentConfiguration();
					},

					/** @public
						@instance
					*/
					removeRelatedProduct: function(ref) {
						removeRelatedProduct(ref, config);
					},

					/** @public
						@instance
					*/
					saveAndContinue: function(callback) {
						var screenIdx = ancestors.length > 0 ? ancestors[ancestors.length-1].index : undefined;

						saveAndContinue(this.config);
						if (api.productHasChanged) {
							api.productHasChanged(currentProductId, screenIdx);
						}
						this.validateCurrentConfig();
						this.displayScreen(screenIdx, callback);
						CS.Rules.evaluateAllRules();
					},

					/** @public
						@instance
					*/
					selectConfiguration : function(ref) {
						selectConfiguration(ref, config);
					},

					/** @public
						@instance
					*/
					setAttributeField: setAttributeField,

					/** @public
						@instance
					*/
					persistConfiguration: function(basketSpec, rootConfig, callback) {
						if (typeof rootConfig === 'function') {
							callback = rootConfig;
							rootConfig = config;
						}
						persistConfiguration(api, rootConfig, basketSpec, callback);
					},

					/** @public
						@instance
					*/
					validateCurrentConfig: function(highlight) {
						return validateScreens(config, currentScreen.reference, highlight);
					},

					/** @public
						@instance
					*/
					validateScreen: function(idx) {
						return validateScreens(config, {reference: currentScreen.reference, index:idx});
					}
				};

				jQuery.extend(api, delegate);

				if (rootProductId) {
					api.loadProduct(rootProductId, function productIsLoaded(model) {
						if (!configurationData) {
							createConfiguration(config, '', rootProductId);
							continueLoadProduct();
						} else {
							if (!configurationData[''].config[prefix + 'Index__c']) {
								configurationData[''].config[prefix + 'Index__c'] = 0;
							}
							// TODO - match loaded data to current definition structure
							loadConfiguration(api, config, '', configurationData, continueLoadProduct);
						}

						function continueLoadProduct() {
							selectConfiguration('', config);



							var msg = Util.validateProperties(api, 'Service Delegate', {
								'function': [
									'loadDefinition'
								]
							});
							if (msg) {
								return error(msg);
							}

							containerSelector = domSelector;

							// detach callback so that it can reference this newly created Service
							setTimeout(modelIsLoadedCallback, 50);
						}
					});
				}

				return api;


				/* Internal functions */

				function populateScreens(productId, config) {
					var productIndex = getProductIndex(productId),
						screensByProduct = productIndex.screensByProduct[productId],
						configScreens = [],
						idx = 0,
						attrRefsByDef = {},
						newAttrDefs = productIndex.attributeDefsByProduct[productId],
						defId,
						attrContext = {ref: '', index: 0};

					for (defId in newAttrDefs) {
						ref = Util.generateReference(newAttrDefs[defId].Name, attrContext);
						attrRefsByDef[defId] = ref;
					}

					for (idx in screensByProduct) {
						var screen = screensByProduct[idx],
							attrs = productIndex.attributeDefsByScreen[screen.Id],
							attrRefs = [];

						for (var attrId in attrs) {
							attrRefs.push(attrRefsByDef[attrId]);
						}

						configScreens[idx] = {
							id: screen.Id,
							reference: screen._reference,
							attrs: attrRefs
						};
					}

					config.screens = configScreens;
				}

				function getProductIndex(id) {
					if (!id) {
						id = currentProductId;
					}
					var index = indices[id.substring(0,15)];
					if (!index) {
						Log.warn('Product Index for Id ' + id + ' not loaded');
					}
					return index;
				}

				function createConfiguration(configData, anchorRef, newProductId, parent) {
					var productIndex = getProductIndex(newProductId);

					if (!productIndex) {
						throw 'Product index for ' + newProductId + ' not found';
					}

					var	productDef = productIndex.productsById[newProductId],
						wrapper = configData[anchorRef],
						newAttrDefs = productIndex.attributeDefsByProduct[newProductId],
						screensByProduct = productIndex.screensByProduct[newProductId],
						configScreens = [],
						idx = 0,
						name,
						newConfig = {},
						context,
						attr,
						defId,
						ref;

					if (anchorRef !== ROOT_REFERENCE && !wrapper) {
						return error('Could not locate reference ', anchorRef, configData);
					}

					if (!productDef) {
						return error('Could not find product definition for id', newProductId);
					}

					if (!newAttrDefs) {
						return error('Could not find attribute definitions for product id', newProductId);
					}

					if (anchorRef === ROOT_REFERENCE) {
						// root config
						ref = anchorRef;
					} else {
						// attaching a related product configuration to an attribute on the parent
						idx = wrapper.relatedProducts.length;
						name = wrapper.attr.Name;
						ref = Util.stripReference(anchorRef) + idx;
					}
					context = getContext(ref, name, idx, parent);

					newConfigWrapper = buildConfig(productDef, ref, context);

					Log.info('Creating configuration for reference ' + ref);

					if (anchorRef !== ROOT_REFERENCE) {
						// Link related product to parent and mark as unsaved
						newConfigWrapper.parent = parent;
						newConfigWrapper.unsaved = true;
						var relatedProducts = wrapper.relatedProducts.slice(0);
						relatedProducts[idx] = newConfigWrapper;
						CS.binding.update(anchorRef, {relatedProducts: relatedProducts});
					}

					var attrContext = {ref: context.ref, index: 0};

					for (defId in newAttrDefs) {
						attr = buildAttribute(newAttrDefs[defId], attrContext, productIndex.find('selectOptionsByAttribute', defId), productIndex.find('attributeFieldDefsByAttributeDef', defId));
						configData[attr.reference] = attr;
					}

					populateScreens(newProductId, newConfigWrapper);

					if (configData[ref]) {
						// Overlay config on parent attribute node in configuration for related product #0
						jQuery.extend(configData[anchorRef], newConfigWrapper);
					} else {
						configData[ref] = newConfigWrapper;
					}

					loadRulesForConfig(ref, productDef);

					return newConfigWrapper;
				}

				function removeRelatedProduct(ref, data) {
					var wrapper = data[ref],
						anchorRef = Util.stripReference(ref) + 0,
						anchorWrapper = data[anchorRef],
						idx = Util.getReferenceIndex(ref),
						isLast,
						newIndex,
						relWrapper,
						newRef,
						previousRef,
						numRelatedProducts = anchorWrapper.relatedProducts.length,
						lastRef = Util.stripReference(ref) + (numRelatedProducts - 1);

					checkRelatedProductRefs(anchorRef, data);

					for (var i = idx; i < numRelatedProducts; i++) {
						relWrapper = anchorWrapper.relatedProducts[i];
						previousRef = relWrapper.reference;

						if (i === idx) {
							// Remove the specified related product
							if (i === 0) {
								// Only remove the config from a 0-index node
								delete wrapper.config;
								delete wrapper.parent;
								delete wrapper.unsaved;
							} else {
								// delete the entire node for indices > 0
								delete data[ref];
							}
							deleteChildReferences(ref, data);
							continue;
						} else {
							// re-index subsequent related products in the same list
							newIndex = i - 1;
							isLast = i === numRelatedProducts - 1;
							newRef = Util.stripReference(previousRef) + newIndex;
							reindexChildReferences(data, previousRef, newIndex, newRef, isLast);
							relWrapper.reference = newRef;
							relWrapper.config[prefix + 'Index__c'] = newIndex;
						}
					}
					// Remove the rules bound to the previous last slot in the list
					if (numRelatedProducts > 0) {
						CS.Rules.removeRules(lastRef);
					}
					var relatedProds = anchorWrapper.relatedProducts.slice(0);
					relatedProds.splice(idx, 1);
					CS.binding.update(anchorRef, {relatedProducts: relatedProds});
					if (ref == api.getCurrentConfigRef()) {
						api.cancelCurrentConfiguration();
					}
				}

				function checkRelatedProductRefs(anchorRef, data) {
					var relatedProducts = data[anchorRef].relatedProducts,
						numRelatedProducts = relatedProducts.length,
						refPrefix = Util.stripReference(anchorRef);

					for (var i = 0; i < numRelatedProducts; i++) {
						var nodeRef = refPrefix + i,
							node = data[nodeRef],
							relProdNode = relatedProducts[i];

						//CS.Log.info('Node ' + i + ': ' + node.reference + ' / ' + node.config.cscfga__Index__c);
						//CS.Log.info('RelProdNode ' + i + ': ' + relProdNode.reference + ' / ' + relProdNode.config.cscfga__Index__c);

						if (CS.Util.getReferenceIndex(node.reference) !== i) {
							CS.Log.warn(nodeRef + ': incorrect node reference ' + node.reference + ' corrected to ' + i);
							node.reference = refPrefix + i;
							if (node.config.cscfga__Index__c !== i) {
								CS.Log.warn(nodeRef + ': incorrect node index ' + node.config.cscfga__Index__c + ' corrected to ' + i);
								node.config.cscfga__Index__c = i;
							}
						}

						if (CS.Util.getReferenceIndex(relProdNode.reference) !== i) {
							CS.Log.warn(nodeRef + ': incorrect relProdNode reference ' + relProdNode.reference + ' corrected to ' + i);
							relProdNode.reference = refPrefix + i;
							if (relProdNode.config.cscfga__Index__c !== i) {
								CS.Log.warn(nodeRef + ': incorrect relProdNode index ' + relProdNode.config.cscfga__Index__c + ' corrected to ' + i);
								relProdNode.config.cscfga__Index__c = i;
							}
						}
					}
				}

				function saveAndContinue(data) {
					var wrapper = data[currentScreen.reference];
					if (wrapper.unsaved) {
						delete wrapper.unsaved;
					}
					if (ancestors.length === 0) {
						Log.error('Continue invoked, but not in related product context', currentScreen.reference);
					} else {
						var ancestor = ancestors[ancestors.length - 1]; //ancestors.pop();
						selectConfiguration(ancestor.reference, data);
						currentScreen.index = ancestor.index;
					}
				}

				function selectConfiguration(reference, data) {
					var currentWrapper = data[currentScreen.reference],
						anchorRef = Util.getAnchorReference(reference),
						wrapper = data[anchorRef],
						productDef,
						productId,
						context;

					// currentWrapper will be undefined if the related product is being deleted
					// rather than canceled, and we are at related product index > 0
					if (currentWrapper && currentWrapper.unsaved) {
						Log.debug('Cancel unsaved related product, removing', currentScreen.reference);
						removeRelatedProduct(currentScreen.reference, data);
					}

					if (!wrapper) {
						Log.error('Configuration not found for reference', reference, data);
						return;
					}

					productId = wrapper.config[prefix + 'Product_Definition__c'];

					//Log.error('TODO - validation on change of product level');

					var idx = 0; //CS.Util.getReferenceIndex(reference);
					productDef = getProductIndex(productId).all[productId];

					if (!wrapper.screens) {
						populateScreens(productId, wrapper);
					}

//					loadRulesForConfig(reference, productDef); // just in case, this can probably now be removed

					if (ancestors.length === 0) {
						if (reference) {
							ancestors.push({
								reference: currentScreen.reference,
								index: currentScreen.index
							});
						}
					} else {
						for (var i = 0; i < ancestors.length; i++) {
							if (reference === ancestors[i].reference) {
								ancestors.length = i;
								break;
							}

							if (i === ancestors.length - 1) {
								ancestors.push({
									reference: currentScreen.reference,
									index: currentScreen.index
								});
								break;
							}
						}
					}

					currentScreen = {
						reference: reference,
						index: 0
					};
					currentProductId = wrapper.config[prefix + 'Product_Definition__c'];
					return wrapper;
				}

				function validateScreens(data, spec, highlight) {
					var index = getProductIndex(),
						result = {
							isValid: true,
							fieldErrors: {},
							screens: {}
						},
						configRef = typeof spec === 'object' ? spec.reference : spec,
						screenIndex = typeof spec === 'object' ? spec.index : undefined,
						wrapper = data[configRef],
						screens = wrapper ? wrapper.screens : undefined;

					if (highlight === undefined) {
						highlight = true;
					}

					if (!screens) {
						Log.error('No screens found for validation');
						return result;
					}

					if (screenIndex || screenIndex === 0) {
						result = doScreenValidation(data, screens[screenIndex], highlight);
						if (highlight) {
							wrapper.screens[screenIndex].validation = result;
						}
					} else {
						jQuery.each(screens, function (i, screen) {
							var r = doScreenValidation(data, screen, highlight);
							if (highlight) {
								wrapper.screens[i].validation = r;
							}
							jQuery.extend(result.screens, r.screens);
							if (!r.isValid) {
								result.isValid = false;
								if (highlight) {
									jQuery.extend(result.fieldErrors, r.fieldErrors);
								}
							}
						});
					}

					return result;
				}

				function doScreenValidation(data, screen, highlight) {
					var result = {
							isValid: true,
							fieldErrors: {},
							screens: {}
						};

					if (highlight === undefined) {
						highlight = true;
					}

					result.screens[screen.id] = true;
					jQuery.each(screen.attrs, function (i, ref) {
						var it = data[ref];
						var valueField = prefix + 'Value__c';
						if (it && it.attr) {
							if (it.attr[prefix + 'Is_Required__c'] && it.attr[prefix + 'is_active__c'] &&
									!it.attr[prefix + 'Hidden__c'] &&
									(it.attr[valueField] == null || it.attr[valueField] === '' ||
										(it.displayInfo === 'Select List' && it.attr[valueField] === '--None--')
									)
								) {
								result.fieldErrors[ref] = {validationError: true, validationMessage: 'This value is required'};
								result.screens[screen.id] = false;
								result.isValid = false;
								if (highlight) {
									CS.binding.update(ref, result.fieldErrors[ref]);
								}
							} else {
								if (highlight) {
									CS.binding.update(ref, {validationError: false, validationMessage: undefined});
								}
							}
						}
					});

					return result;
				}

			})(delegate, domSelector, rootProductId, configurationData);
		}
	};

	return Service;
});

/*
	CS UI LIBRARY
*/

define('src/csui',[
	'./csbase',
	'./csutil',
	'./csdatabinder'
], function(CS, Util, DataBinder) {
	var Log = CS.Log,
		effectsQueue = {},
		prefix = Util.configuratorPrefix,
		queueTimer,
		uiIsLive = true,
		deferredUpdates = {},
		DISABLE = 'DISABLE',
		ENABLE = 'ENABLE',
		DISABLE_CONTROLS = 'DISABLE_CONTROLS',
		ENABLE_CONTROLS = 'ENABLE_CONTROLS',
		GREY_OUT = 'GREY_OUT',
		MAKE_OPAQUE = 'MAKE_OPAQUE',
		MARK_REQUIRED = 'MARK_REQUIRED'
		;

	var effectsRegistry = {
		DISABLE: function(elements) {
			jQuery(elements).attr('disabled', 'disabled');
		},
		ENABLE: function(elements) {
			jQuery(elements).removeAttr('disabled');
		},
		DISABLE_CONTROLS: function(elements) {
			if (Log.isDebugEnabled()) Log.debug('disableControls', elements);
			jQuery(elements).hide();
		},
		ENABLE_CONTROLS: function(elements) {
			if (Log.isDebugEnabled()) Log.debug('enableControls', elements);
			jQuery(elements).show();
		},
		GREY_OUT: function(elements) {
			if (Log.isDebugEnabled()) Log.debug('greyOut', elements);
			jQuery(elements).fadeTo('fast', 0.3);
		},
		MAKE_OPAQUE: function(elements) {
			if (Log.isDebugEnabled()) Log.debug('makeOpaque', elements);
			jQuery(elements).fadeTo('fast', 1);
		},
		MARK_REQUIRED: function(elements, value) {
			if (Log.isDebugEnabled()) Log.debug('markRequired', value, elements);
			if (value) jQuery(elements).removeClass('requiredOff').addClass('requiredOn');
			else jQuery(elements).removeClass('requiredOn').addClass('requiredOff');
		}
	};

	var actionsRegistry = {
		showNextScreen: {
			name: 'NextScreen',

			getLabel: function() {
				return 'Next';
			},
			action: function(service) {
				CS.Rules.evaluateAllRules('Next screen');
				var idx = service.getCurrentScreenIndex();
				service.displayScreen(idx + 1);
			},
			postProcess: function(it, service) {
				var idx = service.getCurrentScreenIndex(),
					productId = service.getCurrentProductId(),
					screens = service.getProductIndex().screensByProduct[productId];
				if (!screens || idx >= screens.length - 1) {
					it.css('display', 'none');
				}
			}
		},
		showPreviousScreen: {
			name: 'PreviousScreen',

			getLabel: function() {
				return 'Previous';
			},
			action: function(service) {
				CS.Rules.evaluateAllRules('Previous screen');
				var idx = service.getCurrentScreenIndex();
				service.displayScreen(idx - 1);
			},
			postProcess: function(it, service) {
				var idx = service.getCurrentScreenIndex();
				if (idx === 0) {
					it.css('display', 'none');
				}
			}
		},
		saveAndFinish: {
			name: 'SaveAndFinish',

			getLabel: function() {
				return 'Finish';
			},
			action: function() {
				CS.Rules.evaluateAllRules('Save and finish');
				Log.info('Save and finish...');
			}
		}
	};

	function resetEffectsQueue() {
		effectsQueue = {};
	}

	function hide(el) {
		if (el && el.hide) {
			el.hide();
		}
	}

	function show(el) {
		if (el && el.show) {
			el.show();
		}
	}

	function wrapConfiguratorAction(action, name, binding) {
		return _.debounce(function(e) {
			Log.debug(name);
			var el = jQuery(e.currentTarget),
				group = el.attr('data-cs-group'),
				ref = el.attr('data-cs-ref'),
				json = el.attr('data-cs-params'),
				params = json ? JSON.parse(json) || {} : {},
				ret;

			params.el = el;
			params.group = group;
			params.ref = ref;
			//params.ref = binding.wrapper.reference;

			el.attr('disabled', 'disabled');
			try {
				ret = action(params, binding, e);
			} catch (err) {
				Log.error(err.message, err);
			} finally {
				el.removeAttr('disabled');
			}

			return ret ? ret : false;

		}, 500, true);
	}


	var UI = {
		'CALCULATION': 'Calculation',
		'CHECKBOX': 'Checkbox',
		'DATE_PICKER': 'Date',
		'LOOKUP': 'Lookup',
		'RADIO_BUTTON': 'Radio Button',
		'RELATED_PRODUCT': 'Related Product',
		'SELECT_LIST': 'Select List',
		'TEXT_DISPLAY': 'Text Display',
		'USER_INPUT': 'User Input',

		Actions: {
			find: function(name) {
				if (!name || typeof name !== 'string') return Log.warn('Cannot find action - no action name supplied');
				var action = actionsRegistry[name.toLowerCase()];
				if (!action) {
					Log.warn('Could not find action with name ' + name);
				}
				return action;
			},
			register: function(name, action) {
				if (!name || typeof name !== 'string') return Log.warn('Cannot register action - no action name supplied');
				var key = name.toLowerCase();
				action.name = name;
				if (actionsRegistry[key] !== undefined) {
					Log.info('Overwriting existing action for key ' + key);
				}
				actionsRegistry[name.toLowerCase()] = action;
			}
		},

		Checkboxes: {
			isChecked: function(value) {
				if (typeof(value) === 'string') {
					value = value.toLowerCase();
					return value === 'yes' || value === 'true';
				}

				return value ? true : false;
			}
		},

		Effects: {
			markRequired: effectsRegistry.MARK_REQUIRED,

			queue: function queue(effect, elements) {
				Log.debug('Queue effect:', effect, elements);

				var queued = effectsQueue[effect],
					elementsArray = jQuery.makeArray(elements);
				if (!queued) queued = effectsQueue[effect] = elementsArray;
				else effectsQueue[effect] = queued.concat(elementsArray);
				Log.debug('New queue', queued);
				if (queueTimer) {
					Log.debug('Effects queue timer cleared');
					clearTimeout(queueTimer);
				}
				queueTimer = setTimeout(this.runQueue, 10);
				Log.debug('Effects queue timer set');
			},

			processEffects: function processEffects(binding, displayHandler) {
				if (uiIsLive) {
					UI.Effects.updateUI(binding, displayHandler);
				} else {
					Log.debug('UI updates suspended, deferring');
					deferredUpdates[binding.id] = {binding: binding, displayHandler: displayHandler};
				}
			},

			runDeferredUpdates: function runDeferredUpdates() {
				for (var id in deferredUpdates) {
					try {
						var update = deferredUpdates[id];
						UI.Effects.updateUI(update.binding, update.displayHandler);
					} catch (e) {
						Log.error(e);
					}
				}
				deferredUpdates = {};
			},

			updateUI: function updateUI(binding, displayHandler) {
				var wrapper = binding.wrapper,
					attr = wrapper.attr;

				Log.debug('Update UI', binding);

				var elements,
					controls,
					adv = attr[prefix + 'Display_Value__c'],
					av = attr[prefix + 'Value__c'],
					showValidation = true,
					displayValue = adv == null || adv == '' ? av : adv;

				displayHandler.updateDisplay(binding.element, av, displayValue);

				// Disabled
				if (!attr[prefix + 'is_active__c']) {
					elements = binding.element.slice(0);
					controls = [];
					jQuery.each(binding.dataBinder.getLabels(wrapper.reference), function(i, it) {
						elements.push(it['[data-cs-label]']);
					});
					jQuery.each(binding.dataBinder.getControls(wrapper.reference), function(i, it) {
						elements.push(it['[data-cs-control]']);
						controls.push(it['[data-cs-control]']);
					});
					UI.Effects.queue(GREY_OUT, elements);
					UI.Effects.queue(DISABLE_CONTROLS, controls);

					displayHandler.updateDisplay(binding.element, undefined);
					showValidation = false;

					UI.Effects.queue(DISABLE, binding.element);

					binding.uiState.disabled = true;
				} else {
					if (binding.uiState.disabled) {
						elements = binding.element.slice(0);
						controls = [];
						jQuery.each(binding.dataBinder.getLabels(wrapper.reference), function(i, it) {
							elements.push(it['[data-cs-label]']);
						});
						jQuery.each(binding.dataBinder.getControls(wrapper.reference), function(i, it) {
							elements.push(it['[data-cs-control]']);
							controls.push(it['[data-cs-control]']);
						});
						UI.Effects.queue(MAKE_OPAQUE, elements);
						UI.Effects.queue(ENABLE_CONTROLS, controls);

						UI.Effects.queue(ENABLE, binding.element);

						binding.uiState.disabled = false;
					}
				}

				// Read-only
				if (attr[prefix + 'Is_Read_Only__c']) {
					elements = elements || [];
					controls = [];
					jQuery.each(binding.dataBinder.getControls(wrapper.reference), function(i, it) {
						elements.push(it['[data-cs-control]']);
						controls.push(it['[data-cs-control]']);
					});
					UI.Effects.queue(DISABLE_CONTROLS, controls);
					UI.Effects.queue(DISABLE, binding.element);

					binding.uiState.readOnly = true;
				} else {
					if (binding.uiState.readOnly) {
						controls = [];
						jQuery.each(binding.dataBinder.getControls(wrapper.reference), function(i, it) {
							elements.push(it['[data-cs-control]']);
							controls.push(it['[data-cs-control]']);
						});
						UI.Effects.queue(ENABLE_CONTROLS, controls);
						UI.Effects.queue(ENABLE, binding.element);

						binding.uiState.readOnly = false;
					}
				}

				// Required
				var indicators = [],
					indicatorBindings = binding.dataBinder.getRequiredIndicators(binding.wrapper.reference);

				jQuery.each(indicatorBindings, function(i, it) {
					if (it['[data-cs-required]']) {
						indicators.push(it['[data-cs-required]']);
					}
				});
				displayHandler.markRequired(indicators, attr[prefix + 'is_active__c'] && attr[prefix + 'Is_Required__c']);

				// Validation
				if (showValidation) {
					if (displayHandler.showValidation) {
						displayHandler.showValidation(binding.element);
					}
				} else {
					if (displayHandler.clearValidation) {
						displayHandler.clearValidation(binding.element);
					}
				}
			},

			populateLabels: function(binding) {
				var wrapper = binding.wrapper,
					labels = binding.dataBinder.getLabels(wrapper.reference),
					definition = CS.Service ? CS.Service.getProductIndex().all[wrapper.definitionId] : undefined;

				if (!definition) {
					CS.Log.warn('Could not find definition for wrapper ', wrapper);
				} else {
					jQuery.each(labels, function(i, it) {
						var label = definition[prefix + 'Label__c'];
						if (!label) label = definition.Name;
						if (label) {
							jQuery(it['[data-cs-label]']).html(label);
						}
					});
				}
			},

			registerEffect: function(name, func, override) {
				if (effectsRegistry[name] && !override) throw('Effect already registered with name ' + name);
				effectsRegistry[name] = func;
			},

			runQueue: function() {
				Log.debug('Run effects queue...');
				for (var effect in effectsQueue) {
					effectsRegistry[effect](effectsQueue[effect]);
				}
				resetEffectsQueue();
			}

		},

		resumeUpdates: function resumeUpdates() {
			uiIsLive = true;
			UI.Effects.runDeferredUpdates();
		},

		suspendUpdates: function suspendUpdates() {
			uiIsLive = false;
		}

	};


	/* CALCULATION */

	DataBinder.registerHandler(UI.CALCULATION, (function UI_Calculation() {
		return {
			name: 'Calculation',

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						var el = jQuery(element);
						if (el.is('input')) el.val(displayValue);
						else el.html(displayValue);
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				if (properties.hasOwnProperty('value')) {
					var value = properties.value,
						def = wrapper.definition,
						dataType;

					if (!def) {
						def = CS.Service.getProductIndex()[all][wrapper.definitionId];
						wrapper.definition = def;
					}
					dataType = def[prefix + 'Data_Type__c'];

					if (dataType === 'Integer') {
						properties.displayValue = parseInt(value, 10) || (value == 0 ? 0 : value);
					} else if (dataType === 'Double') {
						properties.displayValue = parseFloat(value) || value;
					} else {
						properties.displayValue = value;
					}
				}
				DataBinder.applyProperties(wrapper, properties);
			}
		};
	})());


	/* CHECKBOX */

	DataBinder.registerHandler(UI.CHECKBOX, (function UI_Checkbox() {
		function updateControl(f, value) {
			if (value !== undefined && UI.Checkboxes.isChecked(value)) f.attr('checked', 'checked');
			else f.removeAttr('checked');
		}

		return {
			init: function(binding) {
				var value = binding.wrapper.attr[prefix + 'Value__c'],
					el = jQuery(binding.element);
				updateControl(el, value);
				if (Log.isDebugEnabled()) Log.debug('Registered Checkbox handler for ' + binding.wrapper.reference + ': #' + binding.element.id);
			},

			name: 'Checkbox',

			onChange: function(binding, ref, e) {
				binding.dataBinder.update(ref, {value: jQuery(e.target).is(':checked')}, e);
			},

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function (element, value, displayValue) {
						var f = jQuery(element);
						updateControl(f, displayValue);
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
						msg;

						if (wrapper.validationError) {
							msg = wrapper.validationMessage || 'Please correct this entry';
							jQuery(element).parents('[data-role="fieldcontain"]').addClass('attributeError').append('<p class="attributeErrorMessage">' + msg + '</p>');
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				var value = properties.value,
					propsCopy = jQuery.extend({}, properties);

				if (value !== undefined) {
					wrapper.attr[prefix + 'Value__c'] = wrapper.attr[prefix + 'Display_Value__c'] = UI.Checkboxes.isChecked(value) ? 'Yes' : 'No';
				}

				delete propsCopy.value;
				DataBinder.applyProperties(wrapper, propsCopy);
			}
		};
	})());


	/* DATE PICKER */

	DataBinder.registerHandler(UI.DATE_PICKER, (function UI_DatePicker() {
		return {
			name: 'Date',

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						jQuery(element).val(displayValue);
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				if (properties.hasOwnProperty('value')) {
					properties.displayValue = properties.value;
				}
				DataBinder.applyProperties(wrapper, properties);
			}
		};
	})());


	/* LOOKUP */

	DataBinder.registerHandler(UI.LOOKUP, (function UI_Lookup() {
		function initControls(binding) {
			var controls = jQuery(binding.element).parent().find('[data-cs-action][data-cs-ref^="' + Util.stripReference(binding.wrapper.reference) + '"]');

			binding.controls = {};

			jQuery.each(controls, function(i, it) {
				var j = jQuery(it),
					name = j.attr('data-cs-action'),
					action = CS.UI.Actions.find(name),
					func = action ? wrapConfiguratorAction(action.action, name, binding) : undefined;

				Log.info('Wiring control ' + name + ' with action', action);

				if (func && !j.data('CS.init')) {
					j.on('click.CS', func).css({cursor: 'pointer'}).data('CS.init', true);
				}
			});

			var controlGroups = CS.binding.getControls(binding.wrapper.reference);
			jQuery.each(controlGroups, function(i, it) {
				var ctrl = jQuery(it['[data-cs-control]']);
				binding.controls[ctrl.attr('data-cs-type')] = ctrl;
			});
		}

		function updateControls(binding) {
			var hasEntries = binding.wrapper.attr[prefix + 'Value__c'],
				add = binding.controls.Add,
				del = binding.controls.Del,
				clear = binding.controls.Clear;

			if (hasEntries) {
				if (add) {
					hide(add);
				}
				if (clear) {
					show(clear);
				}
				if (del) {
					show(del);
				}
			} else {
				if (add) {
					show(add);
				}
				if (clear) {
					hide(clear);
				}
				if (del) {
					hide(del);
				}
			}
		}

		function updateLookupList(element, wrapper, continuation) {
			var val = wrapper.attr[prefix + 'Value__c'],
				ids = val ? val.split(',') : [],
				records = _.map(ids, function(it) { return CS.lookupRecords[it]; }),
				tpl = jQuery('#CS\\.MultiSelectLookup__tpl')[0],
				html,
				anchorRef = CS.Util.getAnchorReference(CS.Util.getParentReference(wrapper.reference)),
				config = CS.Service.config[anchorRef].config,
				prodDefId = config ? config.cscfga__Product_Definition__c : undefined,
				definition = CS.Service ? CS.Service.getProductIndex(prodDefId).all[wrapper.definitionId] : {},
				cols = definition.cscfga__List_Columns__c ? definition.cscfga__List_Columns__c.split(',') : [];

			if (!tpl) {
				return Log.error('Cannot find multi-select lookup template');
			}

			try {
				html = Util.template(tpl.innerHTML, {
					wrapper: wrapper,
					definition: definition,
					records: records,
					cols: cols
				});
				element.html(html);
			} catch (e) {
				Log.info('Could not populate content for ', wrapper.reference, e);
			}
			if (continuation) {
				continuation();
			}
		}

		return {
			init: function(binding) {
				initControls(binding);
			},

			name: 'Lookup',

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						var wrapper = binding.wrapper,
							anchorRef = CS.Util.getAnchorReference(CS.Util.getParentReference(wrapper.reference)),
							config = CS.Service.config[anchorRef].config,
							prodDefId = config ? config.cscfga__Product_Definition__c : undefined,
							definition = CS.Service ? CS.Service.getProductIndex(prodDefId).all[wrapper.definitionId] : {};

						if (definition[prefix + 'Max__c'] == 1 || !definition[prefix + 'Enable_Multiple_Selection__c']) {
							var record = CS.lookupRecords[value],
								val = '';
							if (record) {
								val = record.Name || record.name;
							}
							jQuery(element).val(val);
						} else {
							updateLookupList(binding.element, binding.wrapper, function(){
								initControls(binding);
							});
						}
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);
				updateControls(binding);

				if (triggerEvent) el.change();
			}
		};
	})());


	/* RADIO BUTTON */

	DataBinder.registerHandler(UI.RADIO_BUTTON, (function UI_RadioButton() {
		function updateElement(jEl, ref, value) {
			var options = jEl.find('input[type="radio"][name="' + ref + '__list"]');
			jQuery.each(options, function(i, it) {
				it.checked = (it.value == value);
			});
		}

		return {
			init: function(binding) {
				var attr = binding.wrapper.attr,
					index = binding.dataBinder.getIndex();
					//options = index.find('selectOptionsByAttribute', attr[prefix + 'Attribute_Definition__c']);

				//this.setOptions(binding, options);
				this.listHasChanged(binding);
				updateElement(jQuery(binding.element), binding.wrapper.reference, attr[prefix + 'Value__c']);
			},

			name: 'Radio Button',

			setOptions: function(binding, newOptions) {
				var options = binding.wrapper.selectOptions = [],
						i = 0;
				while (newOptions && i < newOptions.length) {
					options.push(newOptions[i++]);
				}
				this.listHasChanged(binding);
			},

			listHasChanged: function(binding) {
				if (binding.offScreen) {
					return;
				}

				var wrapper = binding.wrapper,
						el = jQuery(binding.element),
						options = wrapper.selectOptions,
						tpl = el.attr('data-cs-template'),
						value = wrapper.attr[prefix + 'Value__c'],
						html = Util.template(tpl, {wrapper: wrapper, options: wrapper.selectOptions});

				el.html(html).find('input[type="radio"][name="' + wrapper.reference + '__list"]').change((function(ref){
					return function(e) {
						binding.dataBinder.update(ref, {value: jQuery(binding.element).find('input[type="radio"][name="' + ref + '__list"]:checked').val()});
					};
				})(wrapper.reference));

				if (el.find('input[type="radio"][name="' + wrapper.reference + '__list"][value="' + value + '"]').size() === 0) {
					wrapper.attr[prefix + 'Value__c'] = options[0][prefix + 'Value__c'];
				}
			},

			update: function(binding, properties, triggerEvent) {
				if (properties.selectOptions) {
					if (properties.selectOptions === 'reset') {
						properties.selectOptions = binding.dataBinder.getIndex().find('selectOptionsByAttribute', binding.wrapper.attr[prefix + 'Attribute_Definition__c']);
					}
					this.setOptions(binding, properties.selectOptions);
					// if (jQuery.mobile) jQuery(binding.element).trigger('create');
				}
			},

			updateUI: function(binding, triggerEvent) {
				var wrapper = binding.wrapper;
				var displayHandler = {
					updateDisplay: (function(ref) {
						return function(element, value, displayValue) {
							var el = jQuery(element);
							updateElement(el, ref, displayValue);
							// if (jQuery.mobile) el.find('input').checkboxradio('refresh');
						};
					})(binding.wrapper.reference),

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				var value = properties.value,
						options = wrapper.selectOptions,
						i = options.length,
						propsCopy = jQuery.extend({}, properties);

				while (i--) {
					if (options[i][prefix + 'Value__c'] === value) {
						wrapper.attr[prefix + 'Value__c'] = value;
						wrapper.attr[prefix + 'Price__c'] = options[i][prefix + 'Price__c'];
						break;
					}
				}

				delete propsCopy.value;
				DataBinder.applyProperties(wrapper, propsCopy);
			}
		};
	})());


	/* RELATED PRODUCT */

	DataBinder.registerHandler(UI.RELATED_PRODUCT, (function UI_RelatedProduct() {
		function initControls(binding) {
			var controls = jQuery(binding.element).parent().find('[data-cs-action][data-cs-ref^="' + Util.stripReference(binding.wrapper.reference) + '"]');

			binding.controls = {};

			jQuery.each(controls, function(i, it) {
				var j = jQuery(it),
					name = j.attr('data-cs-action'),
					action = CS.UI.Actions.find(name),
					func = action ? wrapConfiguratorAction(action.action, name, binding) : undefined;

				Log.info('Wiring control ' + name + ' with action', action);

				if (func && !j.data('CS.init')) {
					j.on('click.CS', func).css({cursor: 'pointer'}).data('CS.init', true);
				}
			});

			var controlGroups = CS.binding.getControls(binding.wrapper.reference);
			jQuery.each(controlGroups, function(i, it) {
				var ctrl = jQuery(it['[data-cs-control]']);
				binding.controls[ctrl.attr('data-cs-type')] = ctrl;
			});
		}

		function updateControls(binding) {
			var hasEntries = binding.wrapper.relatedProducts.length > 0,
				add = binding.controls['Add'],
				editDel = binding.controls['EditDel'];

			if (hasEntries) {
				if (add) {
					hide(add);
				}
				if (editDel) {
					show(editDel);
				}
			} else {
				if (add) {
					show(add);
				}
				if (editDel) {
					hide(editDel);
				}
			}
		}

		function updateProductList(element, wrapper, continuation) {
			var defKey = prefix + 'Product_Definition__c',
				index,
				products = _.map(wrapper.relatedProducts, function(it) { return it.config[defKey]; }),
				synchroniser = CS.Util.callbackSynchroniser(displayProductList);

			_.each(products, function(id, i) {
				index = CS.Service.getProductIndex(id);
				if (!index) {
					CS.Log.Warn('Load Product Model - check with loadConfigurationTemplate impl in master branch');
					synchroniser.register('Load Product Model ' + id, function() {
						CS.Service.loadProduct(id, synchroniser.complete('Load Product Model ' + id));
					});
				}
			});

			synchroniser.start();

			function displayProductList() {
				var tpl = jQuery('#CS\\.MultipleRelatedProduct__tpl')[0],
					html,
					anchorRef = CS.Util.getAnchorReference(CS.Util.getParentReference(wrapper.reference)),
					config = CS.Service.config[anchorRef].config,
					prodDefId = config ? config.cscfga__Product_Definition__c : undefined,
					definition = CS.Service ? CS.Service.getProductIndex(prodDefId).all[wrapper.definitionId] : {},
					cols = definition.cscfga__List_Columns__c ? definition.cscfga__List_Columns__c.split(',') : [],
					colSpecs = {};

				if (!tpl) {
					return Log.error('Cannot find related product template');
				}

				jQuery.each(cols, function(i, it) {
					var index = CS.Service.getProductIndex(products[0]),
						attrs = index ? _.filter(index.attributeDefsByProduct[products[0]], function(x) { return x.Name === it.trim(); }) : [],
						attrRef,
						header;

					if (attrs.length > 0) {
						header = attrs[0].cscfga__Label__c || attrs[0].Name;
						attrRef = attrs[0][Util.offlinePrefix + 'Reference_Name__c'] + '_0';
						colSpecs[it] = {header: header, ref: attrRef};
					} else {
						colSpecs[it] = {header: it};
					}
				});

				try {
					html = Util.template(tpl.innerHTML, {
						anchor: wrapper,
						definition: wrapper.definition,
						relatedProducts: wrapper.relatedProducts,
						cols: cols,
						colSpecs: colSpecs
					});
					element.html(html);
				} catch (e) {
					Log.info('Could not populate content for ', wrapper.reference, e);
				}
				if (continuation) {
					continuation();
				}
			}
		}

		return {
			init: function(binding) {
				initControls(binding);
			},

			name: 'Related Product',

			updateUI: function(binding, triggerEvent) {
				var wrapper = binding.wrapper,
					anchorRef = CS.Util.getAnchorReference(CS.Util.getParentReference(wrapper.reference)),
					config = CS.Service.config[anchorRef].config,
					prodDefId = config ? config.cscfga__Product_Definition__c : undefined,
					definition = CS.Service ? CS.Service.getProductIndex(prodDefId).all[wrapper.definitionId] : {},
					displayHandler = {
						updateDisplay: function(element, value, displayValue) {
							if (definition[prefix + 'Max__c'] == 1) {
								jQuery(element).val(displayValue);
							} else {
								updateProductList(binding.element, binding.wrapper, function(){
									initControls(binding);
								});
							}
						},

						markRequired: UI.Effects.markRequired,

						clearValidation: function(element) {
							jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
						},

						showValidation: function(element) {
							var wrapper = binding.wrapper,
								el,
								msg;

							if (wrapper.validationError) {
								el = jQuery(element);
								msg = wrapper.validationMessage || 'Please correct this entry';
								var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
								if (errorContainer.size() === 0) {
									el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
								} else {
									errorContainer.text(msg);
								}
							} else {
								this.clearValidation(element);
							}
						}
					};

				UI.Effects.processEffects(binding, displayHandler);
				updateControls(binding);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				var propsCopy = jQuery.extend({}, properties),
					relatedProducts = properties.relatedProducts;

				if (relatedProducts) {
					wrapper.relatedProducts = relatedProducts;
					if (relatedProducts.length > 0) {
						propsCopy.displayValue = relatedProducts[0].config.Name;
					} else {
						propsCopy.displayValue = '';
					}
					delete propsCopy.relatedProducts;
				}

				DataBinder.applyProperties(wrapper, propsCopy);
			}
		};
	})());


	/* SELECT LIST */

	DataBinder.registerHandler(UI.SELECT_LIST, (function UI_SelectList() {
		return {
			init: function(binding) {
				var wrapper = binding.wrapper,
					index = binding.dataBinder.getIndex(),
					options = wrapper.selectOptions ? wrapper.selectOptions : index.find('selectOptionsByAttribute', wrapper.attr[prefix + 'Attribute_Definition__c']);

				this.setOptions(binding, options);
			},

			name: 'Select List',

			setOptions: function(binding, newOptions) {
				var options = binding.wrapper.selectOptions = [],
					wrapper = binding.wrapper,
					value = wrapper.attr[prefix + 'Value__c'],
					i = 0,
					newOption,
					selectedOption;

				while (newOptions && i < newOptions.length) {
					newOption = newOptions[i++];
					options.push(newOption);
					if (newOption[prefix + 'Value__c'] == value) {
						selectedOption = newOption;
					}
				}

				if (!selectedOption && options.length > 0) {
					selectedOption = options[0];
				}

				wrapper.attr[prefix + 'Value__c'] = selectedOption ? selectedOption[prefix + 'Value__c'] : '';
				wrapper.attr[prefix + 'Display_Value__c'] = selectedOption ? selectedOption.Name : '';

				this.listHasChanged(binding);
			},

			listHasChanged: function(binding) {
				if (binding.offScreen) {
					return;
				}

				var el = jQuery(binding.element),
					wrapper = binding.wrapper,
					options = wrapper.selectOptions,
					value = wrapper.attr[prefix + 'Value__c'];

				el.html('');
				jQuery.each(options, function(i, it) {
					el.append('<option ' + (it[prefix + 'Value__c'] == wrapper.attr[prefix + 'Value__c'] ? 'selected="selected" ' : '') + 'value="' + it[prefix + 'Value__c'] + '" data-cs-sequence="' + it[prefix + 'Sequence__c'] + '" data-cs-price="' + it[prefix + 'Price__c'] + '">' + it.Name + '</option>');
				});
			},

			update: function(binding, properties, triggerEvent) {
				var index = binding.dataBinder.getIndex(),
					attr = binding.wrapper.attr;

				Log.debug('Select List handler update', binding, properties, triggerEvent);

				if (properties.selectOptions) {
					if (properties.selectOptions === 'reset') {
						properties.selectOptions = index.find('selectOptionsByAttribute', attr[prefix + 'Attribute_Definition__c']);
					}
					this.setOptions(binding, properties.selectOptions);
				}
			},

			updateAttribute: function(wrapper, properties) {
				var value = properties.value || wrapper.attr[prefix + 'Value__c'], // value may have changed due to new set of options
					options = wrapper.selectOptions,
					i = options.length,
					propsCopy = jQuery.extend({}, properties);

				while (i--) {
					if (options[i][prefix + 'Value__c'] === value) {
						wrapper.attr[prefix + 'Value__c'] = value;
						wrapper.attr[prefix + 'Price__c'] = options[i][prefix + 'Price__c'];
						wrapper.attr[prefix + 'Display_Value__c'] = options[i].Name;
						break;
					}
				}

				delete propsCopy.value;
				DataBinder.applyProperties(wrapper, propsCopy);
			},

			updateUI: function(binding, triggerEvent) {
				var attr = binding.wrapper.attr;

				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						var f = jQuery(binding.element),
							current = f.find('[selected="selected"]'),
							next = f.find('[value="' + Util.cssEscape(value) + '"]');

						current.removeAttr('selected');
						if (value !== undefined) next.attr('selected', 'selected');
						// if (jQuery.mobile) f.selectmenu('refresh');
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};
				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();

			}
		};
	})());


	/* TEXT DISPLAY */

	DataBinder.registerHandler(UI.TEXT_DISPLAY, (function UI_TextDisplay() {
		return {
			name: 'Text Display',

			onChange: function() {
				// no-op
			},

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						jQuery(element).html(value);
					},

					markRequired: UI.Effects.markRequired
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();

			},

			updateAttribute: function(wrapper, properties) {
				if (properties.hasOwnProperty('value')) {
					properties.displayValue = properties.value;
				}
				DataBinder.applyProperties(wrapper, properties);
			}
		};
	})());


	/* USER INPUT */

	DataBinder.registerHandler(UI.USER_INPUT, (function UI_UserInput() {
		return {
			name: 'User Input',

			updateUI: function(binding, triggerEvent) {
				var displayHandler = {
					updateDisplay: function(element, value, displayValue) {
						jQuery(element).val(displayValue);
					},

					markRequired: UI.Effects.markRequired,

					clearValidation: function(element) {
						jQuery(element).parents('[data-role="fieldcontain"]').removeClass('attributeError').find('.attributeErrorMessage').remove();
					},

					showValidation: function(element) {
						var wrapper = binding.wrapper,
							el,
							msg;

						if (wrapper.validationError) {
							el = jQuery(element);
							msg = wrapper.validationMessage || 'Please correct this entry';
							var errorContainer = el.parents('[data-role="fieldcontain"]').addClass('attributeError').find('p.attributeErrorMessage');
							if (errorContainer.size() === 0) {
								el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');
							} else {
								errorContainer.text(msg);
							}
						} else {
							this.clearValidation(element);
						}
					}
				};

				UI.Effects.processEffects(binding, displayHandler);

				if (triggerEvent) el.change();
			},

			updateAttribute: function(wrapper, properties) {
				if (properties.hasOwnProperty('value')) {
					properties.displayValue = properties.value;
				}
				DataBinder.applyProperties(wrapper, properties);
			}
		};
	})());

	return UI;
});

/**
 	@namespace CS
 */
define('src/cs-full', [
	'src/csapp',
	'src/csbase',
	'src/cscore',
	'src/csdatabinder',
	'src/csog',
	'src/csrules',
	'src/csservice',
	'src/csui',
	'src/csutil',
	'src/cs-sfdc',
	'src/cs-localstore',
	'src/cs-database'
], function(App, CS, Core, DataBinder, OG, Rules, SVC, UI, Util, SFDC, LocalStore, DB) {
	CS.App = App;
	CS.DataBinder = DataBinder;
	CS.OG = OG;
	CS.Rules = CS.rules = Rules; // lower case for legacy compatibility
	CS.SVC = SVC;
	CS.UI = UI;
	CS.Util = Util;
	CS.SFDC = SFDC;
	CS.LocalStore = LocalStore;
	CS.DB = DB;
	
	return CS;
});
