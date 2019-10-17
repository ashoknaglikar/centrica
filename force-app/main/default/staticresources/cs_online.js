
var $j = jQuery.noConflict(),
	actions = {
		changeScreen: function changeScreen() {
			var ref = this.getAttribute('data-cs-ref'),
				screen = CS.Service.getProductIndex().screensByReference[ref];
			
			if (screen) {
				displayScreen(screen.cscfga__Index__c);
			} else {
				CS.Log.warn('Screen ref', ref, 'not found');
			}
		},
		lookup: function lookup(el) {
			var params = JSON.parse(this.getAttribute('data-cs-params')),
				index = CS.Service.getProductIndex(),
				wrapper = CS.Service.config[params.ref],
				definition = index.all[wrapper.definitionId],
				lookupConfigId = definition.cscfga__Lookup_Config__c,
				excludeIds = definition.cscfga__Enable_Multiple_Selection__c ? wrapper.attr.cscfga__Value__c : '';

			jQuery(el).removeAttr('disabled');

			openLookupWindow(params.ref, lookupConfigId, undefined, 800, excludeIds);
		},
		clearLookup: function clearLookup(el) {
			CS.setAttributeValue(this.getAttribute('data-cs-ref'), '');
		}
	};

function launchConfigurator(CS, delegate, params, callback) {
	var configData;

	if (!CS.indicator) {
		initIndicator(CS);
	}

	CS.indicator.start('#indicatorContainer', 0);

	if (params.configId) { // display existing pc
		delegate.loadConfiguration(params.configId, params.definitionId, loadDefinitions);
	} else {
		continueShowEditor(params.definitionId, configData); //display new
	}

	function loadDefinitions(definitionId, configData) {
		var definitionIds = [];

		for (var ref in configData) {
			var node = configData[ref];
			if (node.config) {
				definitionIds.push(node.config.cscfga__Product_Definition__c);
			}
		}

		require(['bower_components/q/q'], function(Q) {
			iterateDefinitions(definitionIds)
			.then(function() {
				continueShowEditor(definitionId, configData);
			})
			.fail(CS.Log.error);

			function iterateDefinitions(defIds) {
				var defId = defIds.shift(),
					d = Q.defer(),
					index = (CS.Service && CS.Service.getProductIndex) ? CS.Service.getProductIndex(defId) : undefined;

				if (defId && !index) {
					CS.Log.info('Pre-loading product definition: ', defId);
					CS.init(delegate, '', defId, undefined, function() {
						CS.Log.info('Loaded product definition:', defId);
						iterateDefinitions(defIds)
						.then(function() {
							d.resolve();
						});
					});

					return d.promise;
				} else {
					return Q.resolve();
				}
			}
		});
	}

	function continueShowEditor(definitionId, configData) {
		CS.Log.info('Displaying product ', definitionId);
		// CS.init - parse product model and create in-memory data structures and CS.Service instance
		CS.init(delegate, '#configurationContainer', definitionId, configData, function() {
			// Build the list of screens for this product...
			var screens = CS.Service.getProductIndex().screensByProduct[definitionId];

			//TMP until fix in core
			if (!CS.Service.config[''].screens) {
				var productIndex = CS.Service.getProductIndex();

				_.each(_.filter(CS.Service.config, function onlyConfigs(it) { return it.config != null; }),
					function buildScreensProperty(it) {
						var screensByProduct = productIndex.screensByProduct[it.config.cscfga__Product_Definition__c],
							configScreens = [],
							attrs = productIndex.attributeDefsByProduct[it.config.cscfga__Product_Definition__c],
							attrRefsByDef = {},
							context = {ref: it.reference};

						 _.each(attrs, function(it) {
							attrRefsByDef[it.Id] = CS.Util.generateReference(it.Name, context);
						 });

						for (var idx in screensByProduct) {
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

						it.screens = configScreens;
					}
				);
			}

			// ...and display in #screensList <OL>
			//populateScreenList(screens);
			
			registerUIActions();                 

			// Display the first (index 0) configuration screen (attributes etc) for this product
			displayScreen(0);
			
			CS.indicator.stop();
			callback();
		});
	}

	function registerUIActions() {
		var Log = CS.Log;

		CS.UI.Actions.register('AddOrEditRelatedProduct', {
			action: function(params) {
				Log.debug('Add or Edit related product action...', params.ref);
				var ref = params.ref,
					el = params.el,
					wrapper = CS.getAttributeWrapper(ref);

				if (!wrapper) {
					Log.error('Cannot find Attribute reference', ref);
					return;
				}

				if (el.jquery) {
					el.attr('disabled', 'disabled').css('opacity', '0.3');
				}

				if (wrapper.relatedProducts.length > 0) {
					editRelatedProduct(params);
				} else {
					addRelatedProduct(wrapper, params);
				}
			}
		});

		CS.UI.Actions.register('AddRelatedProduct', {
			action: function(params) {
				Log.debug('Add related product action...', params.ref);
				var ref = params.ref,
					el = params.el,
					wrapper = CS.getAttributeWrapper(ref);

				if (!wrapper) {
					Log.error('Cannot find Attribute reference', ref);
					return;
				}

				if (el.jquery) {
					el.attr('disabled', 'disabled').css('opacity', '0.3');
				}

				addRelatedProduct(wrapper, params);
			}
		});

		CS.UI.Actions.register('EditRelatedProduct', {
			action: function(params) {
				Log.debug('Edit related product action...', params.ref);
				var ref = params.ref,
					el = params.el,
					wrapper = CS.getAttributeWrapper(ref);

				if (!wrapper) {
					Log.error('Cannot find Attribute reference', ref);
					return;
				}

				if (el.jquery) {
					el.attr('disabled', 'disabled').css('opacity', '0.3');
				}

				editRelatedProduct(params);
			}
		});

		CS.UI.Actions.register('RemoveRelatedProduct', {
			action: function(params) {
				Log.debug('Remove related product...', params.ref);
				CS.Service.removeRelatedProduct(params.ref);
				CS.Rules.evaluateAllRules('Remove related product');
			}
		});

		CS.UI.Actions.register('AddLookup', {
			action: function(params) {
				var el = params.el.get(0);
				actions.lookup.apply(el, [el]);
			}
		});

		CS.UI.Actions.register('RemoveLookup', {
			action: function(params) {
				var wrapper = CS.getAttributeWrapper(params.ref),
					val = wrapper ? wrapper.attr[prefix + 'Value__c'] : '',
					ids = val ? val.split(',') : [],
					newIds;

				newIds = _.filter(ids, function(it) { return it != params.id; });
				CS.setAttributeValue(params.ref, newIds.join(','));
			}
		});

		function addRelatedProduct(wrapper, params) {
			var availableProductOptions,
				availableProducts = [],
				index = CS.Service.getProductIndex();

			Log.debug('Add related product...', params.ref);

			availableProductOptions = index.availableProductsByAttributeDef[wrapper.definitionId] || [];
			var synchroniser = CS.Util.callbackSynchroniser({
				success: function() {
					prepareSelectProduct(params, availableProducts);
				}
			});

			jQuery.each(availableProductOptions, function(i, it) {
				var productId = it.cscfga__Product_Definition__c,
					productIndex = CS.Service.getProductIndex(productId);

				if (!productIndex) {
					synchroniser.register('Load Product Model ' + productId, function() {
						CS.Service.loadProduct(productId, function() {
							productIndex = CS.Service.getProductIndex(productId);
							availableProducts.push(productIndex.all[productId]);
							synchroniser.register('Load Product Templates ' + productId, function() {
								delegate.loadProductTemplateHtml(productId, function() {
									jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(productIndex));
									synchroniser.complete('Load Product Templates ' + productId);
								});
							});
							synchroniser.complete('Load Product Model ' + productId);
						});
					});
				} else {
					availableProducts.push(productIndex.all[productId]);
				}
			});

			synchroniser.start('Loading products');

			function prepareSelectProduct(params, availableProducts) {
				Log.debug('availableProducts:', availableProducts);

				if (availableProducts.length === 1) {
					params.Id = availableProducts[0].Id;
					selectRelatedProduct(params);
				} else {
					controller.changeScreen('SelectRelatedProduct', {products: availableProducts, ref: ref});
				}
			}
		}

		function editRelatedProduct(params) {
			Log.debug('Edit related product...', params.ref);
			var config = CS.Service.config[params.ref],
				productId = config && config.config ? config.config.cscfga__Product_Definition__c : undefined,
				productIndex = productId ? CS.Service.getProductIndex(productId) : undefined,
				synchroniser = CS.Util.callbackSynchroniser({
					success: function() {
						doEditProduct(params);
					}
				});

				if (!productIndex) {
					synchroniser.register('Load Product Model ' + productId, function() {
						CS.Service.loadProduct(productId, function() {
							productIndex = CS.Service.getProductIndex(productId);
							synchroniser.register('Load Product Templates ' + productId, function() {
								delegate.loadProductTemplateHtml(productId, function() {
									jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(productIndex));
									synchroniser.complete('Load Product Templates ' + productId);
								});
							});
							synchroniser.complete('Load Product Model ' + productId);
						});
					});
				}

			synchroniser.start('Ensure product is loaded before edit');

			function doEditProduct(params) {
				CS.Service.selectConfiguration(params.ref);
				if (delegate.productHasChanged) {
					delegate.productHasChanged(CS.Service.getCurrentProductId(), 0);
				}
				displayScreen(0);
			}
		}
	}

	function removeRelatedProduct(params) {
		Log.debug('Remove related product...', params.ref);
		CS.Service.removeRelatedProduct(params.ref);
		CS.Rules.evaluateAllRules('Remove related product');
	}

	function selectRelatedProduct(params) {
		var ref = params.ref,
			productId = params.Id;

		CS.Service.addRelatedProduct(ref, productId, afterDisplay);
	}       
}

function populateLookups(configData, loadLookupRecordUrl, callback) {
	require(['bower_components/q/q'], function(Q) {
		var lookupPromises = [];

		if (!CS.lookupRecords) {
			CS.lookupRecords = {};
		}

		CS.Log.info('Pre-populating lookup data');

		for (var key in configData) {
			if (configData.hasOwnProperty(key)) {
				if (configData[key].attr != undefined && configData[key].displayInfo == 'Lookup') {
					var lookupAttribute = {};

					lookupAttribute.attributeId = configData[key].attr.Id;
					lookupAttribute.attributeValue = configData[key].attr.cscfga__Value__c;
					lookupAttribute.attributeDefinitionId = configData[key].attr.cscfga__Attribute_Definition__r.Id;
					lookupAttribute.attributeLookupConfigId = configData[key].attr.cscfga__Attribute_Definition__r.cscfga__Lookup_Config__c;
					lookupAttribute.attributeObjectMappingId = configData[key].attr.cscfga__Attribute_Definition__r.cscfga__Lookup_Config__r.cscfga__Search_Columns__c;

					if (lookupAttribute.attributeValue) {
						var d = Q.defer();
						lookupPromises.push(d.promise);

						(function(d, lookupAttribute) {
							Visualforce.remoting.Manager.invokeAction(
								loadLookupRecordUrl,
								lookupAttribute,
								function(result, event) {
									try {
										var lookupData = {},
											attKey = lookupAttribute.attributeValue,
											rec = result[attKey] || {};

										for (var attValue in rec) {
											lookupData[attValue] = rec[attValue];
										}

										lookupData.columnMap = rec.columnMap;
										CS.lookupRecords[attKey] = lookupData;

										CS.Log.debug('LookupData for key ', attKey, lookupData);
										
										d.resolve(attKey);
									} catch (e) {
										CS.Log.error('Could not load lookup data for: ', attKey, e.message, e);
										d.reject(e);
									}
								},
								{escape: false}
							);
						})(d, lookupAttribute);
					}
				}
			}
		}

		Q.all(lookupPromises).done(callback);
	});
}

function populateScreenList(screens) {
	var screenHtml = '',
		len = $j(screens).length, //EP added
		currentScreenIdx = CS.Service.getCurrentScreenIndex(),
		snippet;
	
	$j.each(screens, function (i, it) {
		if (i === currentScreenIdx) {
			screenHtml += '<span style="font-weight: bold">' + it.Name + (i == len-1 ? '' : '&nbsp;&gt; ')  + '</span>';
		} else {
			screenHtml += '<span><a href="#" data-cs-ref="' + it._reference + '" data-cs-action="changeScreen">' + it.Name + '</a>' + (i == len-1 ? '' : '&nbsp;&gt; ')  + '</span>';
		}
	});
	$j('#screensList').html(screenHtml);
	applyActions('#screensList');
}

function displayScreen(idx) {
	CS.Service.displayScreen(idx, function() {
		afterDisplay();
	});
}

function afterDisplay() {
	populateScreenList(CS.Service.getProductIndex().screensByProduct[CS.Service.getCurrentProductId()]);
	displayButtons();
	CS.Rules.evaluateAllRules();
	activateControls();        
}

function activateControls() {
	applyActions('#configurationContainer');
}

function clickAction(el, f) {
	var args = arguments.length > 2 ? [].slice.call(arguments, 2) : [];
	if (el.tagName) {
		var group = $j(el).attr('data-cs-group');
		jQuery('button[data-cs-group="' + group + '"]').attr('disabled', 'disabled').css('opacity', '0.3');
	}
	args.push(el);
	f.apply(el, args);
}

function displayButtons() {
	var buttonsHTML = '',
		currentScreenIdx = CS.Service.getCurrentScreenIndex(),
		ref = CS.Service.getCurrentConfigRef(),
		anchor = ref ? CS.Util.getAnchorReference(ref) : '',
		numScreens = CS.Service.config[anchor].screens.length;

	if (currentScreenIdx > 0) {
		buttonsHTML += '<button data-cs-group="Previous" onclick="clickAction(this, displayScreen, ' + (currentScreenIdx - 1) + ')">Previous</button>&nbsp;&nbsp; ';
	}

	if (currentScreenIdx < numScreens - 1) {
		buttonsHTML += '<button data-cs-group="Next" onclick="clickAction(this, displayScreen, ' + (currentScreenIdx + 1) + ')">Next</button>&nbsp;&nbsp; ';
	}

	if (ref === '') {
		buttonsHTML += '<button data-cs-group="Cancel" onclick="clickAction(this, cancel, params.retURL)">Cancel</button>&nbsp;&nbsp; ';
		buttonsHTML += '<button data-cs-group="Finish" onclick="clickAction(this, finish)">Finish</button>&nbsp;&nbsp; ';
	} else {
		buttonsHTML += '<button data-cs-group="Cancel" onclick="clickAction(this, cancelRelated)">Cancel</button>&nbsp;&nbsp; ';
		buttonsHTML += '<button data-cs-group="Finish" onclick="clickAction(this, cont)">Continue</button>&nbsp;&nbsp; ';
	}
	
	jQuery('.CS_configButtons').html(buttonsHTML);
}

function applyActions(scope) {
	var elementsWithActionAttrs = $j(scope).find('[data-cs-action]');
	$j.each(elementsWithActionAttrs, function (i, it) {
		var el = $j(it),
			action = actions[el.attr('data-cs-action')];
		if (action) {
			el.click(function(){
				clickAction(this, action);
			});
		}
	});
}

function cancel(url) {
	location.href = url;
}

function cancelRelated() {
	CS.Service.cancelCurrentConfiguration(afterDisplay);
}

function cont() {
	CS.Service.saveAndContinue(afterDisplay);
}

var popup,
	currentLookupId;

jQuery(window).focus(function() {
	closePopup();
});

window.addEventListener('message', handleMessage);

function handleMessage(event) {
	if (jQuery.browser.msie) {
		closeLookupOverlay();
	}
	
	// set message without encoding (for regular 'raw' string)
	var message = event.data;
	try {
		// base64-decode event.data message in case it's encoded
		message = atob(event.data);
	}
	catch(ex) {}
	
	message = JSON.parse(message);
	
	if (message.action == 'Lookup.SelectRecord') {
		lookupSelect(message.id, message.name, message.data);
	}
}

function openLookupWindow(ref, lookupId, dynamicValueAttributes, width, excludeIds) {
	closePopup();
	window.currentLookupRef = ref;
	
	//#
	//# Dynamic filter from JQuery
	//#
	var nameIdPairs;
	var nameValuePairs;
	var dynamicFilterValues = [];

	var index = CS.Service.getProductIndex(),
		lc = index.all[lookupId],
		lqId = lc ? lc.cscfga__Filter__c : undefined,
		lq = lqId ? index.all[lqId] : undefined,
		referencedAttributes = [],
		parentReference = CS.Util.getParentReference(currentLookupRef),
		attrDef = index.all[CS.getAttributeWrapper(currentLookupRef).definitionId],
		definitionId = attrDef.cscfga__Product_Definition__c,
		isMultiSelect = attrDef.cscfga__Enable_Multiple_Selection__c && attrDef.cscfga__Max__c != 1;

	if (lq) {
		referencedAttributes = JSON.parse(lq.cscfga__Referenced_Attributes__c);
		_.each(referencedAttributes, function(it) {
			var reference = CS.Util.generateReference(it, {ref: parentReference});
			dynamicFilterValues.push(it + '%3D' + CS.getAttributeValue(reference));
		});
	}

	var filterParams = dynamicFilterValues.join('|').replace(/\s/g, "+"),
		field = CS.getAttributeDisplayValue(ref) || '',
		searchValue = isMultiSelect ? '' : field;
	
	if (!jQuery.browser.msie) {
		popup = window.open('/apex/cfgoffline__Lookup?lookupId=' + lookupId + '&searchValue=' + searchValue + '&productDefinitionId=' + definitionId +  '&attributeValues=' + filterParams + '&excludeIds=' + urlEncode(excludeIds ? excludeIds : ''), 'CSlookup', 'width=800, height=480, scrollbars=yes, toolbar=no, location=no, status=no, menubar=no');
	} else {
		jQuery('#popupOverlay')
			.css('display', 'block')
			.on('click', closeLookupOverlay);
		jQuery('#lookupContainer')
			.html('<iframe border="0" height="480" width="800" src="/apex/cfgoffline__Lookup?lookupId=' + lookupId + '&searchValue=' + searchValue + '&productDefinitionId=' + definitionId +  '&attributeValues=' + filterParams + '&excludeIds=' + urlEncode(excludeIds ? excludeIds : '') + '"</iframe>');
	}
}

function closeLookupOverlay() {
	jQuery('#popupOverlay').css('display', 'none');
	jQuery('#lookupContainer').html('');
}

function urlEncode(val) {
	return encodeURIComponent(val).replace(/\s/g, "+");
}

function openCalloutWindow(url, id, params, width) {
	closePopup();
	popup = window.open(url, 'callout', 'width=800, height=480, scrollbars=yes, toolbar=no, location=no, status=no, menubar=no');
}

function closePopup() {
	if (popup) {
		var tmp = popup;
		popup = null;
		tmp.close();
	}
}

function lookupSelect(id, name, data) {
	// copy data so IE does not lose the reference when the window closes
	var localData = {},
		wrapper = CS.getAttributeWrapper(window.currentLookupRef) || {},
		config = CS.getConfigurationWrapper(CS.Util.getAnchorReference(CS.Util.getParentReference(window.currentLookupRef))),
		prodDefId = config ? config.config.cscfga__Product_Definition__c : undefined,
		definition = CS.Service.getProductIndex(prodDefId).all[wrapper.definitionId],
		multiSelectLookup = definition && definition.cscfga__Enable_Multiple_Selection__c && definition.cscfga__Max__c != 1,
		val = wrapper ? wrapper.attr.cscfga__Value__c : undefined,
		ids = val ? val.split(',') : [];
	
	for (key in data) localData[key] = data[key];
					
	if (!multiSelectLookup) {
		val = id;
		CS.getAttributeWrapper(window.currentLookupRef).attr.cscfga__Display_Value__c = name;
//		CS.getAttributeWrapper(window.currentLookupRef).lookupRecord = localData;
	} else {
		ids.push(id);
		val = ids.join(',');
	}
	CS.lookupRecords[id] = localData;
	CS.setAttributeValue(window.currentLookupRef, val);
	CS.rules.evaluateAllRules();
}

function initIndicator(CS) {
	//Damjan Jelas 12/04/2013
	//Indicator extension
	(function(CS) {
		var module = CS.indicator = {};
		module = (function(indicator) {
			var $ = jQuery,
			log = CS.log,
			cssClass = 'indicator',
			cssBackgroundClass = 'indicatorBackground',
			startLast,
			stopLast,
			timer,
			isRunning,
			start = function(selector, miliseconds) {
				if (!CS.isLoadingOverlayEnabled()) {
					return;
				}

				if (isRunning) {
					return;
				}

				if (selector) {
					var container = $(selector);

					//implicit parameter memory, so we can call 'start' after 'stop' on the same element without selector parameter
					startLast = function() {
						if( container.find('.' + cssClass).length === 0){				//don't create elements if they exist
							container.end();
							container.html('<div class="' + cssClass + '"></div>');
							container.append('<div class="' + cssBackgroundClass + '"></div>');
							container.show();
							log('Starting indicator for: ' + selector);
						}
						clearTimer();
					};
					stopLast = function() {
						stop(selector);
					};
				}
				if (startLast) {
					if (!miliseconds) {
						startLast();
					} else{
						//don't create new delayed function if we already have one
						//user should call 'stop' method before 'start' if he want's to re-initialize delay
						if (!timer) {
							timer = setTimeout(startLast, miliseconds);
							log('Setting indicator timer: ID-' + timer + ', Delay-' + miliseconds);
						}
					}
				}
			},
			clearTimer = function() {
				if (timer) {
					log('Removing indicator timer: ID-' + timer );
					clearTimeout(timer);
					timer = null;
				}
			},
			stop = function (selector) {
				if (!CS.isLoadingOverlayEnabled()) {
					return;
				}

				if (selector) {
					var container = $(selector);
					container.children('.' + cssClass ).remove();
					container.children('.' + cssBackgroundClass).remove();
					container.hide();
					log('Stopping indicator for: ' + selector);
				} else {
					clearTimer();
					stopLast && stopLast();
				}
				isRunning = false;
			};
			//expose
			indicator.start = start;
			indicator.stop = stop;
			return indicator;
		})(module || {});
	})(CS);
}