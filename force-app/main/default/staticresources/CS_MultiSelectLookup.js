//# sourceURL=CS_MultiSelectLookup.js
(function() {

	// create a string representation of the microtemplate to use with MultiSelectLookup
	var scriptString = [
	'<script type="text/html" id="CS.MultiSelectLookupWithQuantity__tpl">',
		'<div class="apexp">',
			'<div class="individualPalette">',
				'<div class="Custom24Block">',
					'<div class="bPageBlock brandSecondaryBrd apexDefaultPageBlock secondaryPalette">',
						'<!-- Available records-->',
						'<div class="pbHeader">',
							'<div>',
								'<table border="0" cellpadding="0" cellspacing="0" style="width: 95%;">',
									'<tr>',
										'<td class="pbTitle">',
											'<h2 class="mainTitle">',
												'<span> Flue Parts Available </span>',
											'</h2>',
										'</td>',
									'</tr>',
								'</table>',
							'</div>',
							'<div>',
								'<p><b>&nbsp;</b></p>',
							'</div>',
						'</div>',
						'<div id="bodycontent1" class="pbBody">',
							'<table id="contenttable1" class="relatedProduct" data-cs-type="list" style="width: 95%;">',
								'<thead id="thead001" class="rich-table-thead">',
								'<tr class="headerRow">',
									'<% for(var columnApiName in columnNames) { %>',
									'<th class="headerRow"> <%=columnNames[columnApiName]%> </th>',
									'<% } %>',
									'<th class="headerRow" > Quantity </th>',
								'</tr>',
								'</thead>',
								'<tbody id="tbody001">',
								'<% if (availableRecords && Object.keys(availableRecords).length) {',
									   'for (var key in availableRecords) { %>',
										'<tr>',
											'<% for(var columnApiName in columnNames) { %>',
													'<td class="dataCell" ',
													'<% if (columnApiName == \'Length_Equivalent__c\') { %>',
														' style="text-align: center;" ',
													'<% } %>',
													'>',
													'<%=availableRecords[key][columnApiName]%>',
													'</td>',
											'<% } %>',
											'<td class="dataCell">',
												'<div style="display: flex;">',
												    '<input type="button" ',
												    'class="decrease"', 
												    'onclick="(function decreaseQty() { var tqty = parseInt(window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value,10); var min = <%=availableRecords[key][\'Quantity__c\']%>; console.log(\'decreaseButton> Current minimum is: \' + min); console.log(\'decreaseButton> Current quantity is: \' + tqty); if (!isNaN(tqty) && tqty> 0) { if (min < tqty && min > -1) { tqty--; window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = (tqty==0 ? \'\' : tqty); var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty); } } console.log(\'decreaseButton> New quantity is: \' + window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value); })();"',
												    'value="-"',
												    '<% var curt = quantitiesById[key]; %>', 
												    '<% var mint = availableRecords[key]["Quantity__c"]; %>', 
												    '<% if (availableRecords[key]["Type__c"] == \'Requires\' || (availableRecords[key]["Type__c"] == \'Default\'  &&  mint == curt )) { %>',
                                                        ' disabled ',
                                                    '<% } %>',
												    '>',
												    '<b>&nbsp;</b>',
													'<input type="text"',
														   'data-ref="<%=attributeReference%>"',
														   'data-id="<%=availableRecords[key][\'Part__c\']%>"',
														   'class="multi-lookup-quantity"',
														   'style="width: 2.5rem; text-align: center;"',
														   '<% if (quantitiesById && quantitiesById[key]) { %>',
                                                           'value="<%=quantitiesById[key]%>"',
                                                           '<% } else { %>',
                                                           'value="<%=availableRecords[key][\'Quantity__c\']%>"',
                                                           '<% } %>',
                                                           '<% if (availableRecords[key]["Type__c"] == \'Requires\') { %>',
                                                           'readonly',
                                                           '<% } %>',
														   '/>',
													'<b>&nbsp;</b>',
												    '<input type="button"', 
												    'class="increase"',
												    'onclick="(function increaseQty(){ var tqty = parseInt(window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value, 10); console.log(\'increaseButton> Current quantity is: \' + tqty); if (isNaN(tqty)) { window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = 1; var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty);} else if (!isNaN(tqty) && tqty< 99) { tqty++; window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = tqty; var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty); } console.log(\'increaseButton> New quantity is: \' + window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value); })();"', 
												    'value="+"',
												    '<% if (availableRecords[key]["Type__c"] == \'Requires\') { %>',
                                                        ' disabled ',
                                                    '<% } %>',
												    '>',
												'</div>',
											'</td>',
										'</tr>',
									'<% } %>',
								'<% } else { %>',
								'<tr>',
									'<td class="dataCell" colspan="<%=Object.keys(columnNames).length + 1%>">No data available.</td>',
								'</tr>',
								'<% } %>',
								'</tbody>',
							'</table>',
						'</div>',
						'<!-- Selected records -->',
						'<div class="pbHeader">',
							'<table border="0" cellpadding="0" cellspacing="0" style="">',
								'<tbody>',
									'<tr>',
										'<td>',
											'<input style="padding-top: 6px;padding-right: 8px; padding-bottom: 6px; padding-left: 8px;" type="button" value="+" class="hideNshow" onclick="CS.setAttributeValue(\'Boiler_0:Flue_0:isToggled_0\', !CS.getAttributeValue(\'Boiler_0:Flue_0:isToggled_0\'));">', 
										'</td>',
										'<td><p><b>&nbsp;</b></p></td>',
										'<td>Parts Ordered</td>',
									'</tr>',
								'</tbody>',
							'</table>',
						'</div>',
						'<div id="bodycontent2" class="pbBody">',
							'<table id="contenttable2" class="relatedProduct" data-cs-type="list" style="width: 95%;">',
								'<thead id="thead002" class="rich-table-thead">',
								'<tr class="headerRow">',
									'<% for(var columnApiName in columnNames) { %>',
									'<th class="headerRow"> <%=columnNames[columnApiName]%> </th>',
									'<% } %>',
									'<th class="headerRow" width="104"> Quantity </th>',
								'</tr>',
								'</thead>',
								'<tbody id="tbody002">',
								'<% if (selectedRecords && Object.keys(selectedRecords).length) {',
										'for(var key in selectedRecords) { %>',
											'<tr>',
												'<% for(var columnApiName in columnNames) { %>',
													'<td class="dataCell" ',
													'<% if (columnApiName == \'Length_Equivalent__c\') { %>',
														' style="text-align: center;" ',
													'<% } %>',
													'>',
													'<%=selectedRecords[key][columnApiName]%>',
													'</td>',
												'<% } %>',
												'<td class="dataCell" style="text-align: center;">',
													'<% if (quantitiesById && quantitiesById[key]) { %>',
                                                    '<%=quantitiesById[key]%>',
                                                    '<% } else { %> 0',
                                                    '<% } %>',
												'</td>',
											'</tr>',
										'<% } %>',
								'<% } else { %>',
									'<tr>',
										'<td class="dataCell" colspan="<%=Object.keys(columnNames).length + 2%>">No selected items.</td>',
									'</tr>',
								'<% } %>',
								'</tbody>',
							'</table>',
						'</div>',
						'<div class="pbFooter secondaryPalette">',
							'<div class="bg"></div>',
						'</div>',
					'</div>',
				'</div>',
			'</div>',
		'</div>',
	'</script>'
	].join('');

	var scriptStringOptional = [
	'<script type="text/html" id="CS.MultiSelectLookupWithQuantityOptional__tpl">',
		'<div class="apexp">',
			'<div class="individualPalette">',
				'<div class="Custom24Block">',
					'<div class="bPageBlock brandSecondaryBrd apexDefaultPageBlock secondaryPalette">',
						'<!-- Available records-->',
						'<div class="pbHeader">',
							'<div>',
								'<table border="0" cellpadding="0" cellspacing="0" style="width: 95%;">',
									'<tr>',
										'<td class="pbTitle">',
											'<h2 class="mainTitle">',
												'<span> Optional Parts Available </span>',
											'</h2>',
										'</td>',
									'</tr>',
								'</table>',
							'</div>',
							'<div>',
								'<p><b>&nbsp;</b></p>',
							'</div>',
						'</div>',
						'<div id="bodycontent1" class="pbBody">',
							'<table id="contenttable1" class="relatedProduct" data-cs-type="list" style="width: 95%;">',
								'<thead id="thead001" class="rich-table-thead">',
								'<tr class="headerRow">',
									'<% for(var columnApiName in columnNames) { %>',
									'<th class="headerRow"> <%=columnNames[columnApiName]%> </th>',
									'<% } %>',
									'<th class="headerRow" width="100" > Quantity </th>',
								'</tr>',
								'</thead>',
								'<tbody id="tbody001">',
								'<% if (availableRecords && Object.keys(availableRecords).length) {',
									   'for (var key in availableRecords) { %>',
										'<tr>',
											'<% for(var columnApiName in columnNames) { %>',
													'<td class="dataCell" ',
													'>',
													'<%=availableRecords[key][columnApiName]%>',
													'</td>',
											'<% } %>',
											'<td class="dataCell">',
												'<div style="display: flex;">',
												    '<input type="button" ',
												    'class="decrease"',
												    'onclick="(function decreaseQty() { var tqty = parseInt(window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value,10); var min = 0; if (!isNaN(tqty) && tqty> 0) { if (min < tqty && min > -1) { tqty--; window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = (tqty==0 ? \'\' : tqty); var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty); } } })();"',
												    'value="-"',
												    '<% var curt = quantitiesById[key]; %>',  
												    '<% if (curt == 0 ) { %>',
                                                        ' disabled ',
                                                    '<% } %>',
												    '>',
												    '<b>&nbsp;</b>',
													'<input type="text"',
														   'data-ref="<%=attributeReference%>"',
														   'data-id="<%=availableRecords[key][\'Part_2__c\']%>"',
														   'data-max="<%=availableRecords[key][\'Quantity__c\']%>"',
														   'class="multi-lookup-quantity"',
														   'style="width: 2.5rem; text-align: center;"',
														   '<% if (quantitiesById && quantitiesById[key]) { %>',
                                                                '<% if (quantitiesById[key] > availableRecords[key]["Quantity__c"]) { %>',
                                                                    'value="<%=availableRecords[key]["Quantity__c"]%>"',
                                                                '<% } else { %>',
                                                                    'value="<%=quantitiesById[key]%>"',
                                                                '<% } %>',
                                                            '<% } else { %>',
                                                            'value="0"',
                                                            '<% } %>',
														   '/>',
													'<b>&nbsp;</b>',
												    '<input type="button"', 
												    'class="increase"',
												    'onclick="(function increaseQty(){ var tqty = parseInt(window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value, 10); console.log(\'increaseButton> Current quantity is: \' + tqty); var max = <%=availableRecords[key][\'Quantity__c\']%>; if (isNaN(tqty)) { window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = 1; var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty);} else if (!isNaN(tqty) && tqty < max) { tqty++; window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value = tqty; var elem = window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\'); CS.updateAttributeValue(elem, tqty); } console.log(\'increaseButton> New quantity is: \' + window.jQuery(\'.multi-lookup-quantity[data-id=<%=key%>]\')[0].value); })();"', 
												    'value="+"',
												    '<% var curt = quantitiesById[key]; %>', 
												    '<% var mint = availableRecords[key]["Quantity__c"]; %>', 
												    '<% if (mint <= curt ) { %>',
                                                        ' disabled ',
                                                    '<% } %>',
												    '>',
												'</div>',
											'</td>',
										'</tr>',
									'<% } %>',
								'<% } else { %>',
								'<tr>',
									'<td class="dataCell" colspan="<%=Object.keys(columnNames).length + 1%>">No data available.</td>',
								'</tr>',
								'<% } %>',
								'</tbody>',
							'</table>',
						'</div>',
						'<!-- Selected records -->',
						/*'<div class="pbHeader">',
							'<table border="0" cellpadding="0" cellspacing="0" style="">',
								'<tbody>',
									'<tr>',
										'<td>',
											'<input style="padding-top: 6px;padding-right: 8px; padding-bottom: 6px; padding-left: 8px;" type="button" value="+" class="hideNshow" onclick="CS.setAttributeValue(\'Boiler_0:isToggled_0\', !CS.getAttributeValue(\'Boiler_0:isToggled_0\'));">', 
										'</td>',
										'<td><p><b>&nbsp;</b></p></td>',
										'<td>Parts Ordered</td>',
									'</tr>',
								'</tbody>',
							'</table>',
						'</div>',
						'<div id="bodycontent2" class="pbBody">',
							'<table id="contenttable2" class="relatedProduct" data-cs-type="list" style="width: 95%;">',
								'<thead id="thead002" class="rich-table-thead">',
								'<tr class="headerRow">',
									'<% for(var columnApiName in columnNames) { %>',
									'<th class="headerRow"> <%=columnNames[columnApiName]%> </th>',
									'<% } %>',
									'<th class="headerRow" width="100"> Quantity </th>',
								'</tr>',
								'</thead>',
								'<tbody id="tbody002">',
								'<% if (selectedRecords && Object.keys(selectedRecords).length) {',
										'for(var key in selectedRecords) { %>',
											'<tr>',
												'<% for(var columnApiName in columnNames) { %>',
													'<td class="dataCell" ',
													'>',
													'<%=selectedRecords[key][columnApiName]%>',
													'</td>',
												'<% } %>',
												'<td class="dataCell" style="text-align: center;">',
													'<% if (quantitiesById && quantitiesById[key]) { %>',
                                                    	'<% if (quantitiesById[key] > availableRecords[key]["Quantity__c"]) { %>',
                                                                    '<%=availableRecords[key]["Quantity__c"]%>',
                                                                '<% } else { %>',
                                                                    '<%=quantitiesById[key]%>',
                                                                '<% } %>',
                                                        '<% } else { %>',
                                                            '0',
                                                        '<% } %>',
												'</td>',
											'</tr>',
										'<% } %>',
								'<% } else { %>',
									'<tr>',
										'<td class="dataCell" colspan="<%=Object.keys(columnNames).length + 2%>">No selected items.</td>',
									'</tr>',
								'<% } %>',
								'</tbody>',
							'</table>',
						'</div>',
						*/
						'<div class="pbFooter secondaryPalette">',
							'<div class="bg"></div>',
						'</div>',
					'</div>',
				'</div>',
			'</div>',
		'</div>',
	'</script>'
	].join('');

	// append the string/html to the head tag so it can be retrieved and stored in the component repository
	
	jQuery('head').append(scriptString);
	jQuery('head').append(scriptStringOptional);

	// store the microtemplate to the component repository
	if (CS.isCsaContext) {
		CS.App.Components.Repository.addComponent('configurator', 'MultiSelectLookup', jQuery('head').find('#CS\\.MultiSelectLookupWithQuantity__tpl')[0]);
		CS.App.Components.Repository.addComponent('configurator', 'MultiSelectLookup', jQuery('head').find('#CS\\.MultiSelectLookupWithQuantityOptional__tpl')[0]);
	} else {
		CS.App.Components.Repository.addComponent('configurator', 'MultiSelectLookup', jQuery('#CS\\.MultiSelectLookup__tpl')[0]);
	}

	// initialize the handler function for the multiselectlookup
	CS.DataBinder.registerHandler('MultiSelect Lookup With Quantity', (function UI_MultiSelectLookupWithQuantity() {

		function doMultiRowLookup(lookupConfigId, productDefinitionId, dynamicFilterMap) {

			if (CS.isCsaContext) {

				return new Promise(function(resolve, reject) {
					require(['js/lookup-query-builder', 'js/cs-utility'], function(QueryBuilder, Utility) {

						function getListColumns(lookupConfig) {
							if (!lookupConfig) {
								return;
							}
							var sObjectName = getLookupConfigSobjectName(lookupConfig, 'cscfga__List_Columns__c');
							var fieldLabels = getObjectFieldLabels(sObjectName);
							var fieldMap = CS.Service.getProductIndex().fieldMappingsByObjectMapping[lookupConfig['cscfga__List_Columns__c']];
							var fields = _.pluck(fieldMap, 'cscfga__From_Field__c');
							var fieldSequence = _.pluck(fieldMap, 'cscfga__Sequence__c');
							fields = _.sortBy(fields, function(item, index) {
								return fieldSequence[index];
							});
							if (!fields || !fields.length) {
								fields = ['Name'];
							}
							return generateLabeled(fields, fieldLabels);
						}

						function getLookupConfigSobjectName(lookupConfig, objMappingField) {
							var index = CS.Service.getProductIndex();
							var sObjectName;
							if (lookupConfig['cscfga__Object__c']) {
								sObjectName = lookupConfig['cscfga__Object__c'];
							} else {
								var objectMapping = _.findWhere(index.objectMappingsByName, { Id: lookupConfig[objMappingField] });
								if (objectMapping) {
									sObjectName = objectMapping['cscfga__From_Type__c'];
								}
							}
							return sObjectName;
						}

						function getObjectFieldLabels(sObjectName) {
							var obj = Utility.getValueIC(sObjectName, CS.Metadata.objectMetadata);
							var r;
							if (obj) {
								var fields = _.pluck(obj.fields, 'name');
								var labels = _.pluck(obj.fields, 'label');
								r = _.object(fields, labels);
							}
							return r;
						}

						function generateLabeled(fields, fieldLabelsMap) {
							var results = [];
							for (var i = 0; i < fields.length; i++) {
								var o = {};
								var label = nameToLabel(fields[i], fieldLabelsMap);
								if (label) {
									o[fields[i]] = label;
									results.push(o);
								}
							}
							return results;
						}

						function nameToLabel(name, fieldLabelsMap) {
							if (name.toLowerCase() === 'name') {
								return 'Name';
							}
							return Utility.getValueIC(name, fieldLabelsMap);
						}

						var index = CS.Service.getProductIndex(productDefinitionId);
						var lookupConfig = index.all[lookupConfigId] || {};
						var filter = index.all[lookupConfig['cscfga__Filter__c']] || {};
						var lookupQueryName = filter && filter.Name ? 'Lookup(' + filter.Name + ')' : undefined;
						var query;

						if (CS.DB.config.lookupQueries[lookupQueryName]) {
							query = CS.DB.config.lookupQueries[lookupQueryName]
						} else {
							query = QueryBuilder.buildQuery(lookupQueryName, productDefinitionId);
							query = query[lookupQueryName];
						}

						dynamicFilterMap = dynamicFilterMap ? decodeDynamicFilterMap(dynamicFilterMap) : [];

						_.each(dynamicFilterMap, function(v, k) {
							query = query.replace(new RegExp('\\[' + k + '\\]', 'g'), v);
						});
						query = Utility.replaceBoolWithInt(query);

						CS.DB.smartQuery(query).then(function(qr) {
							return qr.getAll();
						})
						.then(function(records) {

							var listColumns = getListColumns(lookupConfig).reduce(function(acc, curr) { return Object.assign(acc, curr); }, {});

							resolve({
								records: records,
								listColumns: listColumns
							});
						})
						.fail(function(e) {
							CS.Log.error('MultiSelectLookup table query failed: ' + e);
							reject(e);
						});

					});
				});
			} else {

				var MAX_REQUESTS = 2; // every request fetches 25 records
				var payload = {
					"lookupConfigId": lookupConfigId,
					"searchTerm": "",
					"pageNo": 0,
					"productDefinitionId": productDefinitionId,
					"attributeValueParams": dynamicFilterMap
				};

				var promiseArray = [];
				for (var i = 0; i < MAX_REQUESTS; i++) {
					payload.pageNo = i;
					promiseArray.push(queryUISupport(payload));
				}

				return Promise.all(promiseArray);
			}
		}

		function queryUISupport(payload) {

			return new Promise(function(resolve, reject) {
				cscfga.UISupport.getSelectListLookup(
					JSON.stringify(payload),
					"", "", "",
					function callback(result, event) {
						resolve({
							result: result,
							event: event
						});
					}
				);
			});
		}

		function getDynamicFilterMap(attributeRef, lookupQueryObj) {
			var prefix = 'cscfga__';
			var configPrefix = '';
			var attrAbsoluteReferenceAsId = attributeRef || '';
			var n = attrAbsoluteReferenceAsId.lastIndexOf(":");
			if (n !== -1) {
				configPrefix = attrAbsoluteReferenceAsId.substr(0, n);
			}

			var dynamicFilterMap = {};
			var bConfigAttribute = false;
			var attrRef;
			var referencedAttributes = lookupQueryObj ? JSON.parse(lookupQueryObj[prefix + 'Referenced_Attributes__c']) : [];

			jQuery.each(CS.Service.config, function(i, it) {
				if (it.attr) {
					bConfigAttribute = false;
					attrRef = it.reference;
					if (configPrefix !== '' && attrRef.lastIndexOf(configPrefix) !== -1) {
						if (attrRef.substring(n).split(":").length < 3) {
							bConfigAttribute = true;
						}
					}
					if (configPrefix === '' && attrRef.lastIndexOf(':') === -1) {
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

			if(!_.isEmpty(dynamicFilterMap)) {
				var retVal = [];
				for (var key in dynamicFilterMap) {
					retVal.push(key+'='+dynamicFilterMap[key])
				}
				return retVal.join('|');
			} else {
				return "";
			}
		}

		function decodeDynamicFilterMap(filterMap) {
			var dynamicFilterMap = decodeURIComponent(filterMap);

			return _.reduce(dynamicFilterMap.split('|'), function(acc, item) {
				var filterArr = item.split('=');
				acc[filterArr[0]] = filterArr[1];
				return acc;
			}, {});
		}

		function formatCsaLookupResponse(result) {
			var records = _.flatten(result.records)
			.filter(Boolean)
			.reduce(function(acc, curr) {
				var retVal = {};
				retVal[curr.Id] = curr;

				return Object.assign(acc, retVal);
			}, {});

			if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') != -1) {
				for (var item in result.listColumns) {

					if (item == 'Part_Description__c') { 
						result.listColumns['Part_Description__c']='Description';
					} 
				    else if (item == 'Part_Code__c') { 
				    	result.listColumns['Part_Code__c']='Part Code'; 
				    } 
				    else if (item == 'Length_Equivalent__c') { 
				    	result.listColumns['Length_Equivalent__c']='Equivalent Length'; 
				    } 
				    else if (item == 'Quantity__c') { 
				    	result.listColumns['Quantity__c']='Inc'; 
				    } 
				}

				listColumns = _.object(_.without(Object.keys(result.listColumns), 'Part__c', 'Plume_Managment_Part__c'), _.without(Object.values(result.listColumns), 'Part', 'Plume Managment Part'));

				var sortedIds = _.pluck(_.sortBy(records, 'Quantity__c').reverse(), 'Id');
	            var sortedValues = _.sortBy(records, 'Quantity__c').reverse();
	            var sortedrecords = _.object(sortedIds, sortedValues);

				var orderedRecords = _.reduce(sortedIds, function(acc, currentId) {
	                    console.log(currentId);
	                    acc[currentId] = records[currentId];                             
	                    return acc;
	                }, {});

				return {
					records: orderedRecords,
					columnNames: listColumns,
					listColumns: listColumns
				}
			} else {
				for (var item in result.listColumns) {
					if (item == 'Part_2_Code__c') { 
						result.listColumns['Part_2_Code__c']='Part Code';
					}
					else if (item == 'Part_2_Description__c') { 
						result.listColumns['Part_2_Description__c']='Description';
					} 
				}

				listColumns = _.object(_.without(Object.keys(result.listColumns), 'Part_2__c'), _.without(Object.values(result.listColumns), 'Part'));

				var sortedIds = _.pluck(_.sortBy(records, 'Quantity__c').reverse(), 'Id');
	            var sortedValues = _.sortBy(records, 'Quantity__c').reverse();
	            var sortedrecords = _.object(sortedIds, sortedValues);

				var orderedRecords = _.reduce(sortedIds, function(acc, currentId) {
	                    console.log(currentId);
	                    acc[currentId] = records[currentId];                             
	                    return acc;
	                }, {});
				delete listColumns["Quantity__c"];
				return {
					records: orderedRecords,
					columnNames: listColumns,
					listColumns: listColumns
				}
			}
		}

        function formatLookupResponse(result) {
            var records = result.map(function(it) {
                if (it && it.event && it.event.statusCode === 200) {
                    return it.result.records;
                }
            })
            .filter(Boolean)
            .reduce(function(acc, curr) {
                return Object.assign(acc, curr);
            }, {});

            if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') != -1) {
                var columnNames = result[0].result.columnNames.reduce(function(acc, curr) {
                     if (Object.keys(curr) == 'Part_Description__c') { curr['Part_Description__c']='Description';} 
                     else if (Object.keys(curr) == 'Part_Code__c') { curr['Part_Code__c']='Part Code'; } 
                     else if (Object.keys(curr) == 'Length_Equivalent__c') { curr['Length_Equivalent__c']='Equivalent Length'; } 
                     else if (Object.keys(curr) == 'Quantity__c') { curr['Quantity__c']='Min'; } 
                     
                    return Object.assign(acc, curr);
                }, {});

                columnNames = _.object(_.without(Object.keys(columnNames), 'Part__c', 'Plume_Managment_Part__c'), _.without(Object.values(columnNames), 'Part', 'Plume Managment Part'));

                var listColumns = result[0].result.listColumns.reduce(function(acc, curr) {
                    return Object.assign(acc, curr);
                }, {});

                listColumns = _.object(_.without(Object.keys(listColumns), 'Part__c', 'Plume_Managment_Part__c'), _.without(Object.values(listColumns), 'Part', 'Plume Managment Part'));


                var sortedIds = _.pluck(_.sortBy(records, 'quantity__c').reverse(), 'id');
                var sortedValues = _.sortBy(records, 'quantity__c').reverse();
                var sortedrecords = _.object(sortedIds, sortedValues);
                return {
                    records: sortedrecords,
                    columnNames: columnNames,
                    listColumns: listColumns
                }
            } else {
                var columnNames = result[0].result.columnNames.reduce(function(acc, curr) {
                     if (Object.keys(curr) == 'Part_2_Code__c') { curr['Part_2_Code__c']='Part Code';} 
                     else if (Object.keys(curr) == 'Part_2_Description__c') { curr['Part_2_Description__c']='Description';} 
                    return Object.assign(acc, curr);
                }, {});

                columnNames = _.object(_.without(Object.keys(columnNames), 'Part_2__c'), _.without(Object.values(columnNames), 'Part'));

                var listColumns = result[0].result.listColumns.reduce(function(acc, curr) {
                    return Object.assign(acc, curr);
                }, {});

                listColumns = _.object(_.without(Object.keys(listColumns), 'Part_2__c'), _.without(Object.values(listColumns), 'Part'));


                var sortedIds = _.pluck(_.sortBy(records, 'quantity__c').reverse(), 'id');
                var sortedValues = _.sortBy(records, 'quantity__c').reverse();
                var sortedrecords = _.object(sortedIds, sortedValues);

                delete columnNames["Quantity__c"];
                return {
                    records: sortedrecords,
                    columnNames: columnNames,
                    listColumns: listColumns
                }
            }
        }
        
        function calculateTotalLengthEquivalent(lookupResponse, quantitiesById) {
            // Calculate Length Equivalent (Plume and Internal)
            var curQty = 0;
            var curLen = 0;

            var totalLen = 0;
            var plumeLen = 0;

            for (item in quantitiesById) {

                    curLen = parseFloat(lookupResponse[item]["Length_Equivalent__c"]);
                    console.log("curlen=" + curLen);

                    curQty = parseInt(quantitiesById[item], 10);
                    console.log("curQty=" + curQty);
                    
                    if (lookupResponse[item]["Plume_Managment_Part__c"] == true)
                        plumeLen += curLen * curQty;
                    else
                        totalLen += curLen * curQty;
            }

            console.log("Internal Length Calculation =" + totalLen);
            console.log("Plume Kit Length Calculation =" + plumeLen);
            
            // Set Attributes
            if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') != -1) {
                    CS.setAttributeValue("Boiler_0:Flue_0:Total_Length_Equivalent_0", totalLen); 
                    CS.setAttributeValue("Boiler_0:Flue_0:Total_Plume_Kit_Length_0", plumeLen);
            }
        }

		function populateTemplate(binding, lookupResponse) {
			if (!lookupResponse) {
                return;
            }
            var quantitiesById;
            var availableRecords = lookupResponse.records;
            var selectedRecords = {};

            var idsArray = [];
            var valsArray = []; 
            for (item in availableRecords) {
                if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') != -1) {
                    idsArray.push(availableRecords[item].Part__c);
                } else {
                    idsArray.push(availableRecords[item].Part_2__c);
                }
                valsArray.push(availableRecords[item]);
            }
            var availableRecords =  _.object(idsArray, valsArray);
            if (binding.wrapper.attr.cscfga__Value__c) {
                quantitiesById = deserializeValue(binding.wrapper.attr.cscfga__Value__c);
                var recordIds = Object.keys(quantitiesById);

                selectedRecords = _.reduce(Object.keys(availableRecords), function(acc, currentId) {

                    if (_.contains(recordIds, currentId)) {
                        acc[currentId] = availableRecords[currentId];
                    } 
                    return acc;
                }, {});
            }
            else if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') != -1 && binding.wrapper.attr.cscfga__Value__c == '' && CS.getAttributeValue("Boiler_0:Flue_0:Arrangement_0") !== '--None--') {

                selectedRecords = _.reduce(Object.keys(availableRecords), function(acc, currentId) {

                    if (parseInt(availableRecords[currentId].quantity__c, 10)) {
                        acc[currentId] = availableRecords[currentId];
                    } 
                    return acc;
                }, {});

                var includedPartsAndQuantities = "";
                    
                for (var item in availableRecords) {

                    if (parseInt(availableRecords[item].Quantity__c, 10) > 0) {
                        if (includedPartsAndQuantities.length > 0) { 
                            includedPartsAndQuantities = includedPartsAndQuantities + '|' + availableRecords[item].Part__c + ',' + availableRecords[item].Quantity__c;
                        }
                        else
                            includedPartsAndQuantities = availableRecords[item].Part__c + ',' + availableRecords[item].Quantity__c;
                    }
                }

                quantitiesById = deserializeValue(includedPartsAndQuantities);

                CS.setAttributeValue("Boiler_0:Flue_0:Flue_Parts_0", includedPartsAndQuantities);
                
            } else if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') == -1 && binding.wrapper.attr.cscfga__Value__c == '' && CS.getAttributeValue('Boiler_0:Boiler_0') != '') {
                selectedRecords = _.reduce(Object.keys(availableRecords), function(acc, currentId) {

                    if (parseInt(availableRecords[currentId].quantity__c, 10)) {
                        acc[currentId] = availableRecords[currentId];
                    } 
                    return acc;
                }, {});
                var includedPartsAndQuantities = "";
                    
                /*for (var item in availableRecords) {

                    if (parseInt(availableRecords[item].Quantity__c, 10) > 0) {
                        if (includedPartsAndQuantities.length > 0) { 
                            includedPartsAndQuantities = includedPartsAndQuantities + '|' + availableRecords[item].Part_2__c + ',' + availableRecords[item].Quantity__c;
                        }
                        else {
                            includedPartsAndQuantities = availableRecords[item].Part_2__c + ',' + availableRecords[item].Quantity__c;
                        }
                    }
                }*/
                quantitiesById = deserializeValue(includedPartsAndQuantities);
                CS.setAttributeValue("Boiler_0:Optional_Parts_0", "undefined");
            }
            if (CS.Service.getCurrentScreen().reference.indexOf('Flue_Solution') == -1) {
            	if (CS.getAttributeValue('Boiler_0:Boiler_0') != '' && lookupResponse.records && Object.keys(availableRecords).length) {
	        		var tpl = jQuery('#CS\\.MultiSelectLookupWithQuantityOptional__tpl')[0];
	                var html = CS.Util.template(CS.App.Components.Repository.decodeHtml(tpl.innerHTML), {
	                    attributeName: binding.wrapper.attr['Name'],
	                    attributeReference: binding.wrapper.reference,
	                    availableRecords: availableRecords,
	                    selectedRecords: selectedRecords,
	                    columnNames: lookupResponse.columnNames,
	                    quantitiesById: quantitiesById
	                });
	                binding.element.html(html);
	                jQuery('.apexp').css('display', 'block');
	                if( CS.getAttributeValue('Boiler_0:isToggled_0') == true) {
		                //x.style.display = 'block';
		                jQuery('#bodycontent2').css('display', 'block');
		            }
		            else {
		                //x.style.display = 'none';
		                jQuery('#bodycontent2').css('display', 'none');
		            }
	            } else {
                    jQuery('.apexp').css('display', 'none');
                }
            } else {
                calculateTotalLengthEquivalent(availableRecords, quantitiesById);
                
                var tpl = jQuery('#CS\\.MultiSelectLookupWithQuantity__tpl')[0];
                var html = CS.Util.template(CS.App.Components.Repository.decodeHtml(tpl.innerHTML), {
                    attributeName: binding.wrapper.attr['Name'],
                    attributeReference: binding.wrapper.reference,
                    availableRecords: availableRecords,
                    selectedRecords: selectedRecords,
                    columnNames: lookupResponse.columnNames,
                    quantitiesById: quantitiesById
                });
                binding.element.html(html);

                if( CS.getAttributeValue('Boiler_0:Flue_0:isToggled_0') == true) {
	                //x.style.display = 'block';
	                jQuery('#bodycontent2').css('display', 'block');
	            }
	            else {
	                //x.style.display = 'none';
	                jQuery('#bodycontent2').css('display', 'none');
	            }
            } 
            
			// expand the tables to 100%
			jQuery('.apexp').parent().width('100%');
			jQuery('.ui-field-contain').has('.multi-lookup-quantity').css('width', '100%');
			jQuery('.ui-field-contain').has('.multi-lookup-selected-quantity').css('width', '100%');

		}

		var filterMapCache = {};
		var lookupResponseCache = {};

		function getMultiLookupRecords(attributeRef) {
			return lookupResponseCache[attributeRef];
		}

		function urlEncode(val) {
			return encodeURIComponent(val).replace(/\s/g, "+");
		}

		function refreshData(binding, isInit) {

			var definition = CS.Service ? CS.Service.getParentProductIndex(binding.wrapper.reference).all[binding.wrapper.definitionId] : {};
			var lookupConfigObj = CS.Service.getProductIndex(definition.cscfga__Product_Definition__c).all[definition.cscfga__Lookup_Config__c];
			var filterId = lookupConfigObj['cscfga__Filter__c'];
			var lookupQueryObj = CS.Service.getProductIndex(definition.cscfga__Product_Definition__c).all[filterId];
			var dynamicFilterMap = '';
			if (lookupQueryObj) {
				dynamicFilterMap = urlEncode(getDynamicFilterMap(binding.wrapper.reference, lookupQueryObj));
			}

			if (isInit || (dynamicFilterMap !== '' && dynamicFilterMap !== filterMapCache[binding.wrapper.reference])) {

				if (dynamicFilterMap !== filterMapCache[binding.wrapper.reference] && !isInit) {
					binding.wrapper.attr.cscfga__Value__c = '';
				}

				filterMapCache[binding.wrapper.reference] = dynamicFilterMap;

				return doMultiRowLookup(
					definition['cscfga__Lookup_Config__c'],
					definition['cscfga__Product_Definition__c'],
					dynamicFilterMap
				)
				.then(function(response) {
					if (CS.isCsaContext) {
						return formatCsaLookupResponse(response);
					} else {
						return formatLookupResponse(response);
					}
				})
				.then(function(lookupResponse) {
					lookupResponseCache[binding.wrapper.reference] = lookupResponse;
					try {
						populateTemplate(binding, lookupResponse);

						//el.parents('[data-role="fieldcontain"]').append('<p class="attributeErrorMessage">' + msg + '</p>');

					} catch (e) {
						CS.Log.info('Could not populate content for ', binding.wrapper.reference, e);
					}
				});
			} else {
				populateTemplate(binding, lookupResponseCache[binding.wrapper.reference]);
			}
		}

		jQuery(document).on('change', '.multi-lookup-quantity, .multi-lookup-selected-quantity', function(event) {
			var elem = jQuery(this);
			var quantity = getCurrentQuantity(elem);

			updateAttributeValue(elem, quantity);
		});

		// expose the method to enable retrieval of data in js actions
		CS.getMultiLookupRecords = getMultiLookupRecords;

		function getCurrentQuantity(jqElem) {
			return parseInt(jqElem.val(), 10) || 0;
		}

		function updateAttributeValue(jqElem, value) {
			var reference = jqElem.data('ref');
			var recordId = jqElem.data('id');
			var maxVal = jqElem.data('max');
            var newValue = parseInt(value, 10);

            if (maxVal && parseInt(maxVal) != 'NaN' && parseInt(maxVal, 10) < newValue) {
                newValue = parseInt(maxVal, 10);
            }

			var currentAttributeValue = CS.getAttributeValue(reference);
			if (currentAttributeValue.length) {
				var keysValues = deserializeValue(currentAttributeValue);
				if (newValue === 0) {
					delete keysValues[recordId];
				} else {
					keysValues[recordId] = newValue;
				}
				CS.setAttributeValue(reference, serializeValue(keysValues));
			} else {
				if (newValue === 0) {

				} else {
					var val = recordId + ',' + newValue;
					CS.setAttributeValue(reference, val);
				}
			}
		}
		
		CS.updateAttributeValue = updateAttributeValue;

		function deserializeValue(currentAttributeValue) {
			var keyValuePairs = currentAttributeValue.split('|');
			var retArr =_.reduce(keyValuePairs, function(acc, curr) {
				var key = curr.split(',')[0];
				acc[key] = parseInt(curr.split(',')[1], 10) || 1;
				return acc;
			}, {});

			return retArr;
		}

		function serializeValue(keysValues) {
			var retVal = _.reduce(Object.keys(keysValues), function(acc, currKey) {
				var val = keysValues[currKey];
				return acc + currKey + ',' + val + '|';
			}, '');

			return retVal.slice(0, -1);
		}

		var handler = {
			name: 'MultiSelect Lookup With Quantity',
			init: function(binding) {
				refreshData(binding, true);
			},
			onChange: function(binding , attrRef, event) {
				// do nothing, prevent updateAttribute from being triggered
			},
			updateUI: function(binding, triggerEvent) {

				var displayHandler = {

					updateDisplay: function(element, value, displayValue) {
					},
					markRequired: CS.UI.Effects.markRequired
				};
				refreshData(binding, false);
				CS.UI.Effects.processEffects(binding, displayHandler);
			},
			updateAttribute: function(wrapper, properties) {
				if (properties.hasOwnProperty('value')) {
					properties.displayValue = properties.value;
				}
				CS.DataBinder.applyProperties(wrapper, properties);
			}
		};

		return handler;
	})(),
		true);
})();