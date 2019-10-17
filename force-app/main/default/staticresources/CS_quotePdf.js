//# sourceURL=CS_quotePdf.js

/**
 * An object containing all of the possible template types
 * @type {Object}
 */
var TemplateType = {
    asbestos: {
        british: 'Asbestos Risk Form D33227',
        scottish: 'Asbestos Risk Form D33232'
    },
    depositReceipt: {
        british: 'deposit receipt form',
        scottish: 'deposit receipt form',
        htmlTemplate: 'htmlDepositReceipt'
    },
    quote: {
        british: 'quote british',
        scottish: 'quote scottish'
    },
    blankQuote: {
        british: 'quote british blank',
        scottish: 'quote scottish blank'
    },
    customerConfirmationForm: {
        blank: 'customer confirmation blank', 
        withgraphics:'customer confirmation',
        scottish: 'customer confirmation SG'
    },
    notes: {
        british: 'installation template',
        scottish: 'installation template'
    },
    custom: {
        template1: 'template1',
        template2: 'template2',
        template3: 'template3',
        finance_template: 'finance_template'
    }
};

var quoteObjNewTest={};
var quoteHsaName="";
var quoteHsaNum ="";

var mySectionList = [];
var myAllSections = [];


var IFC_DATE_START = "2018-04-03";
var IFC_DATE_END = "2050-12-31";
var IFC_DATE_FINAL = "2050-12-31";

//NEW added 3 July
require(['bower_components/q/q'], function (Q) {

//New Quote
    var PartQuoteItem = function(isPart,sectionId, level, sectionName, partDescription, price, quantity, associatedParts, lineItemId) {
        this.sectionLevel = level;
        this.isPart = isPart;
        this.sectionName = sectionName;
        this.sectionId = sectionId;
        this.partDescription = partDescription;
        this.price = price;
        this.quantity = quantity;
        this.associatedPartsList = associatedParts;
        this.lineItemId = lineItemId;
    };

    var AssociatedPartLineItem = function(sectionId, level, sectionName, partDescription,partQuoteDescription, price, quantity, parentSectionName, parentSectionLevel, lineItemId) {
        this.sectionId = sectionId;
        this.level = level;
        this.sectionName = sectionName;
        this.partDescription = partDescription;
        if(partQuoteDescription!=''){
            this.partDescription = partQuoteDescription;
        }
        this.price = price;
        this.quantity = quantity;
        this.parentSection = parentSectionName;
        this.parentSectionLevel = parentSectionLevel;
        this.lineItemId = lineItemId;
        
    };
    //--end new quote

    var Section = function(id, name, sequence) {
        CS.Log.warn('Added new section with id: ' + id);
        this.Id = id;
        this.Header = name;
        this.Text = '';
        this.Sequence = sequence ? sequence : 100; // if a sequence number isn't found the sequence should be displayed last
        this.SubTotal = formatPrice('0.00');
        this.Products = [];
    };
    
    Section.prototype.addProduct = function(product) {
        this.Products.push(product);
    };
    
    Section.prototype.addToSubtotal = function(amount) {
        var subtotal = Number(this.SubTotal.replace(/[^0-9\.]+/g, ''));
        subtotal += amount;
        this.SubTotal = formatPrice(subtotal);
    };
    
    Section.prototype.concise = function() {
        delete this.Products;
        delete this.Id;
        delete this.Sequence;
    };
    
    /**
     * An entity representing a Product object.
     * @constructor
     */
    var Product = function(id, description) {
        this.Id = id;
        this.Description = description;
        this.SubTotal = formatPrice('0.00');
        this.LineItems = [];
    };
    
    Product.prototype.addLineItem = function(lineItem) {
        //add the line item
        this.LineItems.push(lineItem);
        //recalculate the subtotal
        var subtotal = 0;
        for (var i = 0; i < this.LineItems.length; i++) {
            var lineItemTotal = this.LineItems[i].Total;
            var number = Number(lineItemTotal.replace(/[^0-9\.]+/g, ''));
            subtotal += number;
        }
        this.SubTotal = formatPrice(subtotal);
    };
    
    Product.prototype.clearLineItemTotalsAndQuantities = function() {
        for (var i = 0; i < this.LineItems.length; i++) {
            this.LineItems[i].Total = '';
            this.LineItems[i].Price = '';
            this.LineItems[i].Quantity = '';
        }
    };
    
    /**
     * An entity representing a LineItem object.
     * @constructor
     */
    var LineItem = function(description, quantity, price, total, id) {
        this.Description = description;
        this.Quantity = '(x ' + quantity + ')';
        this.Price = formatPrice(parseFloat(price));
        this.Total = formatPrice(parseFloat(total));
        this.id = id;
    };

    function getParentSection(sectionId, allSectionList) {
        for (var i = 0; i < allSectionList.length; i++) {
            if (allSectionList[i].Id == sectionId) {
                var level1SectionId = allSectionList[i].Level_1_Section__c;
                for (var j = 0; j < allSectionList.length; j++) {
                    if(allSectionList[j].Id == level1SectionId){
                        return allSectionList[j];
                    }
                }                    
            }
        }
        return null;
    }
    
    function getSectionById(sectionId, sectionList) {
        for (var i = 0; i < sectionList.length; i++) {
            if (sectionList[i].Id == sectionId) {
                return sectionList[i];
            }
        }
        return null;
    }

    /**
     * Creates a json object to be passed to the wrapper method along with
     * @return {[type]}
     */
    window.generateQuote = function generateQuote(templateType) {
        
        CS.Log.warn('***** generateQuote called...');
    
        var appointmentId = CS.getAttributeValue('Appointment_Id_0');
    
        function getHeaderData() {
        
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'iPad') {
    
                CS.Log.warn('***** Now calling SmartQuery for get Header Info...');
                
                // Prevent missing Opportunity from stopping pdf generation, split queries (retrieve inner join of Appointment with Opportunity)
                return CS.DB.smartQuery("SELECT {Appointment__c:_soup} FROM {Appointment__c} WHERE {Appointment__c:Id} = '" + appointmentId + "'").then(function(qr) {
                    return qr.getAll().then(function (results) {
                           
                        var params = {};
                        if (results.length > 0) {
                            CS.Log.warn('***** Appointment retrieved: ' + results.length);
                            CS.Log.warn(results[0][0]);
                            var appointment = results[0][0]; //Appointment will exist
                                
                            return CS.DB.smartQuery("SELECT {Opportunity:_soup} FROM {Opportunity} WHERE {Opportunity:Id} = '" + appointment.Opportunity__c + "'").then(function(qr) {
                                return qr.getAll().then(function (r) {
                                    params.app = appointment;
                                             
                                    params.opp = {}; 
                                    if (r && r.length > 0) {
                                        CS.Log.warn('***** Opportunity retrieved: ' + r.length);
                                        CS.Log.warn(r[0][0]);
                                        params.opp = r[0][0];
                                    }

                                    return Q.resolve(params);
                                });
                            });
                        } else {
                            CS.Log.warn('***** No Appointment retrieved');
                            return Q.resolve(params);
                        }
                    });
                })
                .then(function (params) {
                    return getPrimaryContactSmSt(params);
                })
                .fail(function(error) {
                    CS.Log.error(error);
                });

                function getPrimaryContactSmSt(result) {
                    CS.Log.warn('Getting primary contact from smartstore');
                    
                    var appointment = result.app, 
                        opportunity = result.opp;
                    CS.Log.warn('appointment: ' + appointment);
                    CS.Log.warn('opportunity: ' + opportunity);
                    
                    if ( appointment && (typeof appointment) == "string") {
                        appointment = JSON.parse(appointment);
                    }
                    if (opportunity && (typeof opportunity) == "string") {
                        opportunity = JSON.parse(opportunity);
                    }
                    
                    var header = {},
                        installationAddress = {
                            Name: '',
                            Street: '',
                            PostalCode: '',
                            Telephone: '',
                            Mobile: ''
                        },
                        billingAddress = {
                            Name: '',
                            Street: '',
                            PostalCode: '',
                            Telephone: '',
                            Mobile: ''
                        };

                    header.InstallationAddress = installationAddress;
                    header.BillingAddress = billingAddress;
                    header.QuoteNumber = CS.getAttributeValue('Quote_Reference_0');
                    header.Contact = '';
                    header.TransactionId = '';
                    
                    if (!_.isEmpty(appointment)) {
                        header.TransactionId = appointment.CHI_Lead_No__c ? ('' + appointment.CHI_Lead_No__c) : ''; //must be string
                        
                        

                        CS.Log.warn('TransactionId: ' + appointment.CHI_Lead_No__c);
                    }
                    
                    // if Opportunity has not been retrieved, do not proceed to retrieving primary contact
                    if (_.isEmpty(opportunity)) {
                        CS.Log.warn('Opportunity not retrieved.');
                        
                        // If the opportunity has not been retrieved populate with details from the attributes
                        var installAddress = CS.getAttributeValue('Installation_Address_0');
                        if(installAddress) {
                            var installAddressSplit = installAddress.split(',');
                            installationAddress.Street = installAddressSplit[0];
                            installationAddress.PostalCode = installAddressSplit[3];
                        }

                        var billAddress = returnBillingAddress();
                        if(billAddress) {
                            var billAddressSplit = billAddress.split(',');
                            var fullContactName = CS.getAttributeValue('Customer_Name_0') !== null ? CS.getAttributeValue('Customer_Name_0') : '';

                            installationAddress.Name = fullContactName;
                                
                            billingAddress.Name = fullContactName;
                            billingAddress.Street = billAddressSplit[0];
                            billingAddress.PostalCode = billAddressSplit[3];
                        }
                        return Q.resolve(header); // pass an empty object since the method expects a parameter    
                    } else {
                        installationAddress.Street = opportunity.Install_Address_Street__c ? opportunity.Install_Address_Street__c : '';
                        installationAddress.PostalCode = opportunity.Install_Postcode__c ? opportunity.Install_Postcode__c : '';
                        installationAddress.Telephone = opportunity.SC_Home_Phone__c ? opportunity.SC_Home_Phone__c : '';
                        installationAddress.Mobile = opportunity.SC_Mobile_Phone__c ? opportunity.SC_Mobile_Phone__c : '';
                    }
                    
                    var contactLink = opportunity.Contact_Link__c;
                    var contactId = contactLink.substring(contactLink.indexOf('/')+1);
                    contactId = contactId.substring(0, contactId.indexOf('/'));
                    if (!contactId || contactId.length < 15) {
                        CS.Log.warn('Contact id not retrieved.');
                        return Q.resolve(header); // pass an empty object since the method expects a parameter    
                    }
                    contactId = generate18CharId(contactId);
                    CS.Log.warn('***** Contact id to be queried: ' + contactId);
                    return CS.DSA.searchData('Contact', 'Id', contactId)
                        .then(function(results) {
                            CS.Log.warn('*** Contact retrieved: ');
                            CS.Log.warn(results);
                            
                            // Populate Contact related info
                            if (results && results.length > 0) {
                                if(typeof results == 'string'){
                                    results = JSON.parse(results)[0];
                                }
                                contact = results;
                                var fullContactName = (contact.Salutation || '') + ' ' + (contact.FirstName || '') + ' ' + (contact.LastName || '');
                                var billAddressSplit = returnBillingAddress().split(',');

                                installationAddress.Name = fullContactName;
                                
                                billingAddress.Name = fullContactName;
                                billingAddress.Street = billAddressSplit[0] ? billAddressSplit[0] : (contact.MailingStreet ? contact.MailingStreet : '');
                                billingAddress.PostalCode = billAddressSplit[3] ? billAddressSplit[3] : (contact.MailingPostalCode ? contact.MailingPostalCode : '');
                                billingAddress.Telephone = contact.Best_Phone__c ? contact.Best_Phone__c : '';
                                billingAddress.Mobile = contact.MobilePhone ? contact.MobilePhone : '';
                            } else {
                                 CS.Log.warn('Problem: No Contact record has been retrieved for contactId: ' + contactId);
                            }

                            return Q.resolve(header);
                        })
                        .then(function (header) {
                            // Get the quote employee details
                            var hsaId = CS.getAttributeValue('Assigned_To_Employee_0');
                            if(hsaId !== '') {
                                return CS.DB.smartQuery("SELECT {Employee__c:_soup} from {Employee__c} WHERE {Employee__c:Id} = '" + hsaId + "'").then(function(qr) { 
                                    return qr.getAll().then(function(results) {
                                        var assignedToEmployee = results[0][0];
                                        CS.Log.warn("Assigned to employee: ");
                                        CS.Log.warn(assignedToEmployee);
                                        
                                        var hsaName = assignedToEmployee.First_Name__c + ' ' + assignedToEmployee.Last_Name__c,
                                            hsaNumber = assignedToEmployee.Phone_No__c;
                                        header.Contact = 'To discuss or accept your quotation please contact ' + hsaName + ' on ' + hsaNumber + ' or alternatively call us on 0333 202 9488';
                                        return Q.resolve(header);
                                    });
                                });
                            } else {
                                return Q.resolve(header);    
                            }
                        })
                        .fail(function(error) {
                            CS.Log.error(error);
                            return Q.resolve(header); 
                        });
                }
    
            } else if (device == 'Laptop') {
                var deferred = Q.defer();
                CS.Log.warn('Getting header data...');
    
                UISupport.getHeaderData(
                    appointmentId,
                    function(result, event) {
                        if (event.status) {
    
                            var header = {};
                            header.Contact = result.Assigned_To_Name__c ? result.Assigned_To_Name__c : '';
                            header.QuoteNumber = result.CHI_Lead_No__c ? result.CHI_Lead_No__c : '';
    
                            var installationAddress = {};
                            installationAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                            installationAddress.Street = result.Opportunity__r.Install_Address_Street__c ? result.Opportunity__r.Install_Address_Street__c : '';
                            installationAddress.PostalCode = result.Opportunity__r.Install_Postcode__c ? result.Opportunity__r.Install_Postcode__c : '';
                            installationAddress.Telephone = result.Opportunity__r.SC_Home_Phone__c ? result.Opportunity__r.SC_Home_Phone__c : '';
                            installationAddress.Mobile = result.Opportunity__r.SC_Mobile_Phone__c ? result.Opportunity__r.SC_Mobile_Phone__c : '';
    
                            var billingAddress = {};
                            billingAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                            billingAddress.Street = result.Opportunity__r.Account.Primary_Contact__r.MailingStreet ? result.Opportunity__r.Account.Primary_Contact__r.MailingStreet : '';
                            billingAddress.PostalCode = result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ? result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode : '';
                            billingAddress.Telephone = result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c ? result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c : '';
                            billingAddress.Mobile = result.Opportunity__r.Account.Primary_Contact__r.MobilePhone ? result.Opportunity__r.Account.Primary_Contact__r.MobilePhone : '';
    
                            header.InstallationAddress = installationAddress;
                            header.BillingAddress = billingAddress;

                            deferred.resolve(header);
                        } else {
                            deferred.reject('Event failed');
                        }
                    }
                );
                return deferred.promise;
            }
        }
    
        function getSectionList() {
    
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'iPad') {
                CS.Log.warn('***** Now calling SmartQuery for get Section List Info...');
                
                return CS.DB.smartQuery("SELECT {CS_Template_Section_Header__c:_soup} FROM {CS_Template_Section_Header__c} ")
                    .then(function(qr) {
                        return qr.getAll().then(function(results) {
                            CS.Log.warn('Template header results');
                                
                            var resultList = [];
                            for (var i = 0; i < results.length; i++) {
                                resultList.push(results[i][0]);
                            }
                            CS.Log.warn(resultList);

                            return Q.resolve(resultList);
                        });
                    }).fail(function(error) {
                        CS.Log.error(error);
                    });
            } else if (device == 'Laptop') {
                var deferred = Q.defer();

                UISupport.getAllSections(
                    function(result, event) {
                        if (event.status) {

                            deferred.resolve(result);
                        } else {
                            deferred.reject('Event failed');
                        }
                    }
                );
                return deferred.promise; 
            }
        }
        
        Q.all([getHeaderData(), getSectionList()]).then(function(result){
            CS.Log.warn('Q.all result:');
            CS.Log.warn(result[0]);
            CS.Log.warn(result[1]);
            var params = {
                headerData: result[0],
                allSections: result[1]    
            };

            return populateJsonObject(params);
        })
        .fail(function(e) { 
            CS.Log.error(e);
        });
        
    
        /**
         * Used to create a json string to be sent for pdf quote generation.
         * @param {Object} header   an object containing custom header data retreived from server.
         */
        function populateJsonObject(params) {

            var header = params.headerData;
            var allSectionList =  params.allSections;
            
            CS.Log.warn(header);
    
            CS.Log.warn('Populating quote object...');
    
            var quoteObject = {};
            // HEADER - remaining fields are here, no need for redundancy
    
            function toFullMonthDate(d){
                var monthNames = [ "January", "February", "March", "April", "May", "June",
                    "July", "August", "September", "October", "November", "December" ];   
                return monthNames[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
            }
    
            CS.Log.warn('Quote_Creation_Date_0: ' + CS.getAttributeValue('Quote_Creation_Date_0'));
            header.QuoteDate = toFullMonthDate(new Date(CS.getAttributeValue('Quote_Creation_Date_0')));
            CS.Log.warn('QuoteDate: ' + header.QuoteDate);
            
            header.TotalPricePayable = formatPrice(CS.getAttributeValue('Total_Price_Payable_0'));
            header.Deposit = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            header.DepositReference = '' + CS.getAttributeValue('Deposit_Receipt_Number_0');
            header.DepositPaidBy = CS.getAttributeValue('Payment_Type_0');
            
            var balance = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0); 
            header.Balance = formatPrice(balance);
            
            header.BalancePaidBy = CS.getAttributeValue('Payment_Option_0');
    
            quoteObject.Header = header;
    
            // customer needs
            var customerNeeds = "During the visit today, you expressed the following needs and requirements:";
            quoteObject.CustomerNeeds = customerNeeds;
    
            // ************** DETAILS ****************
            var details = {};
            details.Description = CS.getAttributeValue('Reason_for_Quotation_0');
            
            function addLevel1Section(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList){
                var section = getSectionById(sectionId, sectionList); //find if section exists, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionId, sectionName);
                    sectionList.push(section);
                }
                section.Text = (section.Text === '' ? description : (section.Text + '\n' + description)) ;
                section.addToSubtotal(aggregatedPriceInclVAT);
            }
            
            function addLevel2Section(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId){
                var sectionLevel1 = getParentSection(sectionId, allSectionList); // get level 1 section id from all sections list
            
                var section = getSectionById(sectionLevel1.Id, sectionList); // check if a section with that id exists in sectionList, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionLevel1.Id, sectionLevel1.Name);
                    sectionList.push(section);                     
                }
                
                product = getSectionById(sectionId, section.Products); // find a lvl2 section (product) if exists within that section, otherwise create new lvl 2 section
                if (product === null) {
                    product = new Product(sectionId, sectionName);
                    section.addProduct(product);
                }
            
                // add the item as line item
                var lineItem = new LineItem(description, quantity, aggregatedPriceInclVAT, aggregatedPriceInclVAT, lineItemId);
                product.addLineItem(lineItem);
            }
              
            //associated parts - new display
             function extractAssociatedParts(parent){
                 var aPList =[];
                 for (var key in partsModelJS) {
                    if(key == parent){
                        if (partsModelJS.hasOwnProperty(key)) {        
                            //if part
                            if(partsModelJS[key].isPart){
                                if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                                    CS.Log.warn('PART==');
                                    CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                        
                                    
                                    if(partsModelJS[key]['associatedParts'].length>0){
                                        console.log("Associated Parts");
                                        for(var aPart in partsModelJS[key]['associatedParts']){
                                            if(partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c']){
                        
                                                var parentSectionLevel= partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                                                var parentSectionName=partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                        
                                                var sectionId = partsModelJS[key]['associatedParts'][aPart]['part']['CS_Template_Section_Header__c'];
                        
                                                console.log('Part =='+partsModelJS[key]['associatedParts'][aPart]['part']['Description__c']+'  SKill=='+partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c']+'  Price=='+partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT']+' quantity=='+partsModelJS[key]['associatedParts'][aPart]['quantity']);
                                                var aPLI = new AssociatedPartLineItem(sectionId, 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Description__c'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Quote_Description__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['quantity'], 
                                                        parentSectionName,
                                                        parentSectionLevel,
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Id']);
                        
                                                aPList.push(aPLI);
                                            }
                                        }
                                    }
                                    else{
                                        CS.Log.warn('No associated parts');
                                    }
                                    CS.Log.warn('----------');
                                }
                                
                        
                            }
                        
                            //if bundle
                            else{
                                if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                                    CS.Log.warn('BUNDLE==');
                                    CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                                    CS.Log.warn('----------');
                                }
                            }
                        }
                    } 
                }
                return aPList;
             }
            
            function iterateOldQuoteParts(){
                var partsList = [];
            
                for (var key in partsModelJS) {
                    if (partsModelJS.hasOwnProperty(key)) {        
                    //if part
                    if(partsModelJS[key].isPart){
                        if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                        
                            CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                
                            var sectionId = partsModelJS[key]['parentPart']['part']['CS_Template_Section_Header__c'];
                            var isPart = partsModelJS[key].isPart;
                            var level = partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                            var sectionName = partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                            var partDescription = partsModelJS[key]['parentPart']['part']['Quote_Description__c'];
                            var price = partsModelJS[key]['parentPart']['priceVatIncl'];
                            var quantity = partsModelJS[key]['parentPart']['quantity'];
                            var associatedParts = extractAssociatedParts(key);
                            var lineItemId = partsModelJS[key]['parentPart']['part']['Id'];
                            var partItem = new PartQuoteItem(isPart, sectionId, level, sectionName, partDescription, price, quantity, associatedParts, lineItemId);
                                                
            
                           
            
                            partsList.push(partItem);
                        }   
                
                    }
                
                    //if bundle
                    else{
                        if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                            CS.Log.warn('BUNDLE==');
                            CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                            CS.Log.warn('----------');
                        }
                    }
                  }
                } 
            
                return partsList;
            }


            function addAssociatedPartsOldQuote(sectionList, allSectionList){
                var pL = iterateOldQuoteParts();
                    for(p in pL){
                        if(pL[p].associatedPartsList.length>0){
                            for(ap in pL[p].associatedPartsList){
                                
                                if(pL[p].associatedPartsList[ap].level == SectionLevel1){
                                    
                                    addLevel1Section(pL[p].associatedPartsList[ap].sectionId, pL[p].associatedPartsList[ap].sectionName, pL[p].associatedPartsList[ap].partDescription.replace(/\\r\\n/g, ""), pL[p].associatedPartsList[ap].price, sectionList);
                                    
                                    
                                }
                                if(pL[p].associatedPartsList[ap].level == SectionLevel2){
                                    
                                    addLevel2Section(pL[p].associatedPartsList[ap].sectionId, 
                                            pL[p].associatedPartsList[ap].sectionName, 
                                            pL[p].associatedPartsList[ap].partDescription.replace(/\\r\\n/g,""), 
                                            pL[p].associatedPartsList[ap].price, 
                                            pL[p].associatedPartsList[ap].quantity, 
                                            sectionList, 
                                            allSectionList,
                                            pL[p].associatedPartsList[ap].part.id);
                                }
                            }
                        }
                    }
            }
            
            //end
            
            function isRadiatorAttribute(item) {
                var attRef = item.attRef;
                // this checks only the start of the string
                if(attRef.lastIndexOf(radiator, 0) === 0) {
                    if((attRef.indexOf(placeholder)>0) || (attRef.indexOf(actual)>0) || (attRef.indexOf(fittingBundle)>0)) {
                        return true;    
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
                
            function addRadiatorOrFittingBundle(item, radiatorMap, fittingBundleMap) {
                // get reference for map
                var attRef = item.attRef,
                    len = item.attRef.indexOf(":"),
                    index = attRef.substr(0, len);
                
                // add placeholders and actuals to radiator map
                // add fitting bundles to fitting bundle map
                if((attRef.indexOf(placeholder) > 0) || (attRef.indexOf(actual) > 0)) {
                    radiatorMap[index] = item;
                } else if(attRef.indexOf(fittingBundle) > 0) {
                    fittingBundleMap[index] = item;
                }
            }
            
            function addRadiatorsToSectionList(radiatorMap, fittingBundleMap, sectionList, allSectionList) {
                // iterate radiator map
                for (var attRef in radiatorMap) {
                    if (!radiatorMap.hasOwnProperty(attRef)) continue;
                    var rad = radiatorMap[attRef],
                        fittingBundle = fittingBundleMap[attRef];
            
                    // construct radiator and add to section list
                    if(!_.isEmpty(rad)) {
                        var sectionId = rad.parentPart.part.CS_Template_Section_Header__c,
                            sectionName = rad.parentPart.part.Section_Name__c ? rad.parentPart.part.Section_Name__c : '',
                            sectionLevel = rad.parentPart.part.Section_Level__c,
                            description = rad.parentPart.part.Quote_Description__c ? rad.parentPart.part.Quote_Description__c : (rad.parentPart.part.Description__c ? rad.parentPart.part.Description__c : (rad.parentPart.part.Name ? rad.parentPart.part.Name : '')),
                            aggregatedPriceInclVAT = (rad.aggregatedPriceInclVAT || rad.aggregatedPriceInclVAT === 0) ? rad.aggregatedPriceInclVAT : 0;

                             //quantity issue fix
                            var quantity = 1;
                            //if part
                            if(rad.isPart){
                                quantity = rad.parentPart.quantity;
                                CS.Log.warn("NEW QUANTITY FOR PART =="+quantity);
                            }
                        
                            CS.Log.warn('Added quantity fix');

                        if(!_.isEmpty(fittingBundle)) {
                            CS.Log.warn('fitting bundle is not empty');
                            CS.Log.warn(fittingBundle);
                            // construct a description with fitting bundle
                            var fittingBundleName = fittingBundleNameMap[fittingBundle.parentBundle.Fitting_Pack__c];
                            description += ' (' + fittingBundleName + ')';
                            // add the fitting price to the radiator price
                            fittingBundlePrice = (fittingBundle.aggregatedPriceInclVAT || fittingBundle.aggregatedPriceInclVAT === 0) ? fittingBundle.aggregatedPriceInclVAT : 0;
                            aggregatedPriceInclVAT += fittingBundlePrice;
                            //quantity fix
                            if(fittingBundle.isBundle){
                                quantity = fittingBundle.attLastQuantity;
                                CS.Log.warn("NEW QUANTITY FOR BUNDLE =="+quantity);
                            }
                        }

                        // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                        CS.Log.warn('Adding a radiator...');
                        if (sectionLevel === SectionLevel1) { 
                            addLevel1Section(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                        } else if (sectionLevel === SectionLevel2) {
                            addLevel2Section(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, rad.id);
                        }
                    }
                }
            }
            
            var SectionLevel1 = 'Level 1',
                SectionLevel2 = 'Level 2';
                
            var radiator = 'Radiator_',
                actual = 'Actual_Radiator_',
                placeholder = 'Placeholder_',
                fittingBundle = 'Fitting_Bundle_';
            var radiatorMap = {},
                fittingBundleMap = {};
                fittingBundleNameMap = {
                    'New location in same room': 'new fix',
                    'Same place, different size': 'replacement',
                    'Same place, same size': 'replacement',
                    'New installation': 'new installation'
                };
    
            var sectionList = [];
            //iterate through build parts model and create a product structure
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id)) continue;
                var item = partsModelJS[id];
    
                if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
    
                    var quantity = 1;
                    var description = '';
                    var aggregatedPriceInclVAT = (item.aggregatedPriceInclVAT || item.aggregatedPriceInclVAT === 0) ? item.aggregatedPriceInclVAT : 0;
                    var parentPartPrice = 0;
    
                    if (item.isBundle) {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                        quantity = parseInt(item.attLastQuantity, 10) ? parseInt(item.attLastQuantity, 10) : 1;
    
                    } else {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                        quantity = parseInt(item.parentPart.quantity, 10) ? parseInt(item.parentPart.quantity, 10) : 1;
                        parentPartPrice = (item.parentPart.priceVatIncl || item.parentPart.priceVatIncl === 0) ? item.parentPart.priceVatIncl : 0;
                    }
    
                    var section = null;
                    var product = null;
    
                    if(isRadiatorAttribute(item)) {
                        addRadiatorOrFittingBundle(item, radiatorMap, fittingBundleMap);
                    } else {
                        if (item.isPart && !(item.isMultilookup)) {
                            CS.Log.warn('Adding a part...');
                            //get section id, name, level
                            var sectionId = item.parentPart.part.CS_Template_Section_Header__c;
                            var sectionName = item.parentPart.part.Section_Name__c ? item.parentPart.part.Section_Name__c : '';
                            var sectionLevel = item.parentPart.part.Section_Level__c;
                            var lineItemId = item.parentPart.part.Id;
                            
                            // Change made to check the .parentPart.part.Show_Parts__c flag, if the flag is true, show associated parts along with the parent part
                            var showAssociatedParts = item.parentPart.part.Show_Parts__c;
                            if(showAssociatedParts) {
                                // add the parent part
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1Section(sectionId, sectionName, description, parentPartPrice, sectionList);        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2Section(sectionId, sectionName, description, parentPartPrice, quantity, sectionList, allSectionList, lineItemId);
                                }
                                // add the associated parts
                                CS.Log.warn('Adding associated parts...');
                                /* --- associated parts
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    var aPdescription = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var aPquantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var aPpriceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                                    
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1Section(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), sectionList); 
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2Section(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), aPquantity, sectionList, allSectionList);
                                    }
                                }
                                */
                            } else {
                                // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1Section(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                            
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2Section(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId);
                                }
                            }
                        } 
                        else if (item.isBundle) {
                            CS.Log.warn('Adding a bundle...');
                            // Change made to check the .parentBundle.Show_Parts__c flag, if the flag is true, show parts instead of bundle
                            var showParts = item.parentBundle.Show_Parts__c;
                            if (showParts) {
                                // flag is set to true, iterate through all associated parts of the bundle
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    
                                    var description = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var quantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var priceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                        
                                    var sectionId = associatedPart.part.CS_Template_Section_Header__c;
                                    var sectionName = associatedPart.part.Section_Name__c ? associatedPart.part.Section_Name__c : '';
                                    var sectionLevel = associatedPart.part.Section_Level__c;
                                    var lineItemId = associatedPart.lineItemId;
                        
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1Section(sectionId, sectionName, description, (priceVatIncl * quantity), sectionList); 
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2Section(sectionId, sectionName, description, (priceVatIncl * quantity), quantity, sectionList, allSectionList, lineItemId);
                                    }
                                }      
                            } else {
                                var sectionId = item.parentBundle.CS_Template_Section_Header__c;
                                var sectionName = item.parentBundle.Section_Name__c ? item.parentBundle.Section_Name__c : '';
                                var sectionLevel = item.parentBundle.Section_Level__c;
                                
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1Section(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList); 
                        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2Section(sectionId, sectionName, description, aggregatedPriceInclVAT, 1, sectionList, allSectionList, lineItemId);
                                }
                            }
                        }        
                    }
                }
            }
            
            // add the constructed radiators
            addRadiatorsToSectionList(radiatorMap, fittingBundleMap, sectionList, allSectionList);
    
            //associated parts
            addAssociatedPartsOldQuote(sectionList, allSectionList);
            //end
    
            details.Sections = sectionList;
            quoteObject.Details = details;
    
            // FOOTER
            var footer = {
                TotalGrossPrice: formatPrice(CS.getAttributeValue('Gross_Price_incl_VAT_0')),
                NetContractPrice: formatPrice(CS.getAttributeValue('Total_Price_Payable_0'))
            };
    
            CS.Log.warn('Adding discounts...');
            var discountList = new Product(null, 'Discounts:');
            //iterate through applied allowances and add them as line items 
            for (var c = 1; c <= 6; c++) {
                var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                    allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                    allowanceQuantity = '',
                    allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                    allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                    allowanceId = CS.getAttributeValue('Allowance' + c + '_0');

                    if (allowanceDescription == '') {
                        allowanceDescription = allowanceName;
                    }
                // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
                if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                    var lineItem = new LineItem(allowanceDescription, allowanceQuantity, allowancePrice, allowancePrice, lineItemId);
                    discountList.addLineItem(lineItem);
                }
            }
            footer.Discounts = discountList;
    
            quoteObject.Footer = footer;
    
            applySequencesAndDisplayPrices(allSectionList, quoteObject);
        }
    
        function applySequencesAndDisplayPrices(resultList, quoteObject) {
    
            CS.Log.warn('Applying sequences...');
            CS.Log.warn('All Section list: ');
            CS.Log.warn(resultList);
    
            var sectionList = quoteObject.Details.Sections;
            CS.Log.warn(sectionList);
            
            // iterate through all of the sections and apply sequences
            for(var i=0; i<sectionList.length; i++){
                var section = sectionList[i];
                CS.Log.warn('Going through section: ' + section.Header + ' with id: ' + section.Id);
    
                var actualSection = getSectionById(section.Id, resultList);
    
                CS.Log.warn('Actual section: ');
                CS.Log.warn(actualSection);
                section.Sequence__c = actualSection.Sequence__c;
                
                var numOfProducts = section.Products ? section.Products.length : 0;
                CS.Log.warn('Num of section products: ' + numOfProducts);
    
                if (numOfProducts > 0){
                    // iterate through all of the products, apply sequences
                    for(var j=0; j<numOfProducts; j++){
                        var product = section.Products[j];
                        CS.Log.warn('Iterating through product:');
                        CS.Log.warn(product);
    
                        var actualProduct = getSectionById(product.Id, resultList);
                        CS.Log.warn('Actual product is: ');
                        CS.Log.warn(actualProduct);
    
                        product.Sequence__c = actualProduct.Sequence__c;
    
                        CS.Log.warn('Item totals flag: ' + actualProduct.Show_item_totals__c + ' and group totals flag: ' + actualProduct.Show_group_totals__c);
                        // clean line item totals and quantities if necessary for lvl 2 sections
                        if (!actualProduct.Show_item_totals__c) {
                            CS.Log.warn('Cleared line item totals and quantities.');
                            product.clearLineItemTotalsAndQuantities();
                        }
                        if (!actualProduct.Show_group_totals__c) {
                            CS.Log.warn('Cleared subtotals.');
                            product.SubTotal = '';
                            CS.Log.warn(product);
                        }
                    }
                    // sort lvl 2 sections if there are any
                    section.Products.sort(function(a, b) {
                        return a.Sequence__c - b.Sequence__c;
                    });
                    
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                    
                } else {
                    // show concise lvl 1 if it doesnt have lvl 2 sections
                    CS.Log.warn('Section does not have lvl 2 sections.');
                    section.concise();
                    CS.Log.warn(section);
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                }                
            }
    
            sectionList.sort(function(a, b) {
                return a.Sequence__c - b.Sequence__c;
            });
            
            // add a message for low cost quotes (e.g. for low cost pricebooks)
            var isLowCostQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_LowCost ? true : false;
            CS.Log.warn('Is the quote a low cost quote: ' + isLowCostQuote);
            if(isLowCostQuote) {
                var lowCostSection = new Section('noId', 'Quotation details', 0);
                lowCostSection.Text = 'The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.';
                lowCostSection.concise(); // remove the unnecessary section fields
                lowCostSection.SubTotal = ''; // remove the subtotal
                if(sectionList.length > 0) {
                    sectionList.unshift(lowCostSection);
                } else {
                    sectionList.push(lowCostSection);
                }
            }
            
            quoteObject.Details.Sections = sectionList;
            // TODO: 
            var financeTemplateTable = populateFinanceTableInput();
            quoteObject = _.extend(quoteObject, financeTemplateTable);
            //
            createJsonFromObject(quoteObject);
        }
    
        function createJsonFromObject(quoteObject) {
    
            CS.Log.warn('Creating json from object...');
            
            var quoteJSON = JSON.stringify(quoteObject);
            quoteJSON = replaceJsonCharacters(quoteJSON);
            createQuote(quoteJSON, templateType);
        }
    
        function createQuote(quoteJSON, templateType) {
    
            CS.Log.warn(quoteJSON);
    
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'iPad') {
                templateType = (typeof templateType === "undefined") ? TemplateType.quote : templateType;
                var templateName = templateType.british ? templateType.british : templateType[Object.keys(templateType)[0]];
    
                // check whether a customer has a scottish postcode, and use the other template if he has.
                if (isScottishPostcode()) {
                    templateName = templateType.scottish;
                    CS.Log.warn('Using scottish template');
                }
                
                CS.Log.warn('Calling the createQuote method...');

                //STyle

                testStyleJsonQ = {
                "waysToPayTotalAmount": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
                "waysToPayDeposit":     {"font-name" : "Avenir-Book",
                        "font-size" : "9",
                        "underline" : false
                    },
                "waysToPayBalance":     {"font-name" : "Avenir-Book",
                        "font-size" : "9",
                        "underline" : false
                    },
                "CustomerNameAddress1": {
                    "font-name" : "Avenir-Book",
                    "font-size" : "15",
                    "underline" : false
                },
                "Representative": {
                    "font-name" : "Avenir-HeavyOblique",
                    "font-size" : "20",
                    "underline" : false
                },
                "Date": {"font-name" : "Copperplate",
                    "font-size" : "12",
                    "underline" : false
                },
                
                "3_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "3_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "5_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "5_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "8_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "8_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "10_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "10_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "totalAmount": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                }
            };  

            var styleJSON = JSON.stringify(testStyleJsonQ);
            styleJSON = replaceJsonCharacters(styleJSON);

                cordova.exec(
                function(result){
                    CS.Log.warn('Before Timeout Clear');
                    //clearTimeout(timeoutVarQuoteId);
                    CS.Log.warn(result);
                    if(typeof result === "string") result = JSON.parse(result);
                    var quoteSigned = result.signed,
                        quotePath = result.path;
                        
                    CS.Log.warn('quoteSigned: ' + quoteSigned);
                    CS.Log.warn('quotePath: ' + quotePath);
                    
                    CS.setAttributeValue('Pdf_Signed_0', quoteSigned);
                    CS.setAttributeValue('Pdf_Path_0', quotePath);
                }, 
                function(e) { CS.Log.error(e);},
                
                "DSAQuotePlugin", "createWithStyle",[templateName,quoteJSON,styleJSON,true,true]);
            
            }

        }
    };
    


    /**
     * Creates a deposit receipt. Calls the wrapper method to display the pdf.
     */
     window.createDepositReceipt = function createDepositReceipt() {

        var isHTMLversion = false;
        
        isHTMLversionIfOnDevice();
        
        function isHTMLversionIfOnDevice(){
            if(navigator.device) {
                    //check if user is in employee group
                    var userId = CS.SFDC.userId;
                    var inHTMLDeposit = true;
                    generateDepositReceiptTemplate(true);
            }
            else{
                generateDepositReceiptTemplate(false);    
            }
        }
        
        function generateDepositReceiptTemplate(isHTMLversion){
            toggleBtnCss('btn-deposit-receipt');
         
            var paymentMethods = {
                cash: 'Cash',
                card: 'Card',
                cheque: 'Cheque',
                creditCard: 'Credit Card',
                debitCard: 'Debit Card'
            };
        
            var customerNameAddress1 = '',
                creditCard = '',
                cheque = '',
                cash = '',
                customerNameAddress2 = '',
                totalCash = '',
                chequesTotal = '';
        
            /**
             * Creates a customer address from a strings provided by the configurator attribute.
             * @param  {String} name A string from a configurator field containing customer name.
             * @param  {String} addr A string from a configurator field containing all necessary address items.
             * @return {String}      A constructed address.
             */
            function createCustomerNameAndAddress(name, addr, isHTMLversion) {
                var constructedAddress = '',
                    newline = '\n',
                    /*newline = '<br>', does not work with pdf versions*/
                    delimiter = ', ';
                 
                if(isHTMLversion==true){
                    newline = '<br/>';
                }
        
                if (name.length > 0) {
                    constructedAddress += name + newline;
                }
                if (addr.length > 0) {
                    var splitAddress = addr.split(','),
                        billingStreet = splitAddress[0].trim(),
                        billingCity = splitAddress[1].trim(),
                        billingCounty = splitAddress[2].trim(),
                        billingPostCode = splitAddress[3].trim(),
                        billingCountry = splitAddress[4].trim();
        
                    if (billingStreet && billingStreet.length > 0) constructedAddress += billingStreet;
                    if (billingCity && billingCity.length > 0) constructedAddress += newline + billingCity;
                    if (billingCounty && billingCounty.length > 0) {
                        constructedAddress += newline + billingCounty;
                    } else {
                        delimiter = newline;
                    }
                    if (billingPostCode && billingPostCode.length > 0) constructedAddress += delimiter + billingPostCode;
                    if (billingCountry && billingCountry.length > 0) constructedAddress += newline + billingCountry;
                }
                return constructedAddress;
            }
        
            customerNameAddress1 = createCustomerNameAndAddress(CS.getAttributeValue('Customer_Name_0'), returnBillingAddress(), isHTMLversion);
        
            //is customerNameAddress1 equal to customerNameAddress2? Currently it seems like it is
            customerNameAddress2 = customerNameAddress1;
        
            // check the payment method and populate the required fields 
            //WP25439 change
            var paymentMethod = CS.getAttributeValue('Payment_Type_0');
            if (paymentMethod === paymentMethods.cash) {
                cash = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
                totalCash = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            } else if (paymentMethod === paymentMethods.creditCard) {
                creditCard = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            } else if (paymentMethod === paymentMethods.debitCard) {
                creditCard = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            } else if (paymentMethod === paymentMethods.cheque) {
                cheque = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
                chequesTotal = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            }
            
            var str=CS.getAttributeValue('Quote_Creation_Date_0');
            var arr=str.split("-");
            var newDate=arr[2]+"-"+arr[1]+"-"+arr[0];
        
            var jsonObject = {
                CustomerNameAddress1: customerNameAddress1,
                Representative: CS.getAttributeValue('HSA_Name_0'),
                Date: newDate,
                DepositNumber1: '' + CS.getAttributeValue('Deposit_Receipt_Number_0', 'String'),
                CustomerEnquiryNumber: '' + CS.getAttributeValue('CHI_Lead_Number_0', 'String'),
                CreditCard: creditCard,
                Cheque: cheque,
                Cash: cash,
                TotalAmountPaid: formatPrice(CS.getAttributeValue('Actual_Deposit_0')),
                CreditCardAmountPaid: formatPrice(CS.getAttributeValue('Actual_Deposit_0')),
                AuthorizationNumber: '' + CS.getAttributeValue('EPDQ_reference_number_0', 'String'),
                DepositNumber2: '' + CS.getAttributeValue('Deposit_Receipt_Number_0', 'String'),
                CreditAccountNumber: '' + CS.getAttributeValue('Deposit_Receipt_Number_0', 'String'),
                AmountDue: formatPrice(CS.getAttributeValue('Actual_Deposit_0')),
                CustomerNameAddress2: customerNameAddress2,
                TotalCash: totalCash,
                TotalCheques: chequesTotal,
                Total: formatPrice(CS.getAttributeValue('Actual_Deposit_0')),
                DepositNumber3: '' + CS.getAttributeValue('Deposit_Receipt_Number_0', 'String'),
            };
            var jsonString = JSON.stringify(jsonObject);
            jsonString = replaceJsonCharacters(jsonString);
        
            // the Ipad application has this functionality separated from the online version
            if(navigator.device) {
                CS.Log.warn(jsonString);
                
                if(isHTMLversion==true){
                    generateHTMLTemplateWithoutSignature(TemplateType.depositReceipt.htmlTemplate,jsonString)    
                    CS.Log.warn('****Employee is member of HTML Deposit'); 
                }
                else{
                    createTemplate(TemplateType.depositReceipt, jsonString);
                    CS.Log.warn('****Employee is not member of HTML Deposit'); 
                }
                
            } else {
                // start of the online version functionality
                var quoteReference = CS.getAttributeValue('Quote_Reference_0') || '';
    
                jsonObject = JSON.parse(jsonString);
    
                CS.Log.warn(jsonString);
                CS.Log.warn(jsonObject);
    
                var doc = new jsPDF('p', 'mm', [297, 210]);
                doc.setFontSize(10);
                
                // 
                // since IE9 does not support dataurl we need to create a workaround
                // the workaround is to create a pdf and attach it to the Appointment__c related object
                // and the display it to the user
                // 26.03.2015. : another separation was necessary to enable the layout of 
                // the quotes printed in IE9 and in chrome to look the same 
                // (there was a difference how the printer printed the quote based on the browser)
                // 
                // The Sales department uses a standalone printer, so this might not look right
                // if you try to print it using a regular printer - a note from Phil Denisson
                if (navigator.appName == 'Microsoft Internet Explorer' ||  !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv 11/)) || jQuery.browser.msie == 1) {
                    doc.text(20, 50, jsonObject.CustomerNameAddress1);
                    doc.text(125, 70, jsonObject.DepositNumber1);
                    doc.text(125, 82, jsonObject.Date);
                    doc.text(180, 82, jsonObject.CustomerEnquiryNumber);
                    doc.text(20, 95, jsonObject.Representative);
    
                    doc.text(47, 117, jsonObject.CreditCard);
                    doc.text(87, 117, jsonObject.Cheque);
                    doc.text(133, 117, jsonObject.Cash);
                    doc.text(172, 117, jsonObject.TotalAmountPaid);
    
                    doc.text(65, 167, jsonObject.CreditCardAmountPaid);
                    doc.text(153, 167, jsonObject.AuthorizationNumber);
    
                    doc.text(60, 223, jsonObject.DepositNumber2);
                    doc.text(95, 223, jsonObject.CreditAccountNumber);
                    doc.text(150, 234, jsonObject.AmountDue);
    
                    doc.text(95, 258, jsonObject.CustomerNameAddress2);
                    doc.text(122, 285, jsonObject.DepositNumber3);
    
                    doc.text(187, 268, jsonObject.TotalCash);
                    doc.text(187, 275, jsonObject.TotalCheques);
                    doc.text(187, 285, jsonObject.Total);
    
                    var content = btoa(doc.output());
    
                    UISupport.AttachPdfReturnId(
                        CS.params.linkedId,
                        'DepositSlip' + Math.random().toString(36).replace(/[^a-z]+/g, '') + '.pdf',
                        content,
                        function(result, event) {
                            if(event.status) {
                                CS.Log.warn(result);
                                window.open('/servlet/servlet.FileDownload?file=' + result);
                            }
                        }
                    );
                } else {
                    doc.text(20, 40, jsonObject.CustomerNameAddress1);
                    doc.text(120, 60, jsonObject.DepositNumber1);
                    doc.text(120, 72, jsonObject.Date);
                    doc.text(165, 72, jsonObject.CustomerEnquiryNumber);
                    doc.text(20, 95, jsonObject.Representative);
    
                    doc.text(55, 107, jsonObject.CreditCard);
                    doc.text(95, 107, jsonObject.Cheque);
                    doc.text(135, 107, jsonObject.Cash);
                    doc.text(175, 107, jsonObject.TotalAmountPaid);
    
                    doc.text(55, 157, jsonObject.CreditCardAmountPaid);
                    doc.text(125, 157, jsonObject.AuthorizationNumber);
    
                    doc.text(60, 210, jsonObject.DepositNumber2);
                    doc.text(94, 210, jsonObject.CreditAccountNumber);
                    doc.text(136, 224, jsonObject.AmountDue);
    
                    doc.text(95, 248, jsonObject.CustomerNameAddress2);
                    doc.text(120, 275, jsonObject.DepositNumber3);
    
                    doc.text(185, 268, jsonObject.TotalCash);
                    doc.text(185, 275, jsonObject.TotalCheques);
                    doc.text(185, 285, jsonObject.Total);
    
                    doc.output('dataurlnewwindow');
                }
            }  
        }
    };
    
    /**
     * Creates an asbestos form. Calls the wrapper method to display the pdf.
     */
    window.createAsbestosForm = function createAsbestosForm() {
        toggleBtnCss('btn-asbestos');
        
        var jsonObject = {};
        var jsonString = JSON.stringify(jsonObject);
    
        createTemplate(TemplateType.asbestos, jsonString);
    };
    
    
    //Line Break
    window.addLineBreak= function addLineBreak(stringValue){
        var withLineBreak = '';
        
        CS.Log.warn('Adding line breaks---');
        withLineBreak = stringValue.replace(/;/g, "<br/>");
        return withLineBreak;
    }
    
    
    
    /**
     * Calls the wrapper method to display the form based on the provided template
     * type. Check the postcode sector to see whether to display the brittish or
     * the scottish template type.
     * @param  {TemplateType} templateType A type parameter for pdf templates.
     * @param  {Json} jsonString           A json string to be passed to the ipad method.
     */
    window.createTemplate = function createTemplate(templateType, jsonString) {
    
        var device = (navigator.device ? 'iPad' : 'Laptop');
        if (device == 'iPad') {
    
            // set the default template name (the british one) if it doesn't exist, take the first available
            var templateName = templateType.british ? templateType.british : templateType[Object.keys(templateType)[0]];
            CS.Log.warn('Default template name is: ' + templateName);
    
            // check whether a customer has a scottish postcode, and use the other template if he has.
            //if (isScottishPostcode()) {
             checkIfScottishPostcode().then(function(tradeName) { 
                    if(tradeName == 'Scottish Gas'){
                templateName = templateType.scottish;
                CS.Log.warn('Using scottish template: ' + templateName);
            }
    
            CS.Log.warn('Calling the DSAPDFPlugin...');

           
            cordova.exec(function(result){
                        
                        CS.Log.warn(result);var d = Q.defer();d.resolve(result);}, 

                        function(e) { CS.Log.error(e);},
                    "DSAPDFPlugin", "openTemplateWithStyle",[templateName,jsonString,null,true,true]);
             });
        }
    };

//nsa notes logic
    window.openInstallationNotesForm = function openInstallationNotesForm(templateName) {

        if(navigator.device) {
            toggleBtnCss('btn-installation-form');

            // 2019-09-03 customerAddress changed to CS.getAttributeValue('Installation_Address_0') instead of CS.getAttributeValue('Customer_Address_0')
            var instAddr = CS.getAttributeValue('Installation_Address_0');
            if (!instAddr && CS.isCsaContext) {
                var appointmentId = CS.getAttributeValue('Appointment_Id_0');

                CS.DB.smartQuery("SELECT {Appointment__c:_soup} FROM {Appointment__c} WHERE {Appointment__c:Id} = '" + appointmentId + "'").then(function(qr) {
                    return qr.getAll().then(function (results) {
                           
                        if (results.length > 0) {
                            var appointment = results[0][0];
                            return CS.DB.smartQuery("SELECT {Opportunity:_soup} FROM {Opportunity} WHERE {Opportunity:Id} = '" + appointment.Opportunity__c + "'").then(function(qr) {
                                return qr.getAll().then(function (r) {
                                    
                                    if (r && r.length > 0) {
                                        instAddr = r[0][0].Install_Address_Street__c;

                                        instAddr += r[0][0].Install_Address_City__c ? (', ' + r[0][0].Install_Address_City__c) : '';
                                        instAddr += r[0][0].Install_Address_County__c ? (', ' + r[0][0].Install_Address_County__c) : '';
                                        instAddr += r[0][0].Install_Postcode__c ? (', ' + r[0][0].Install_Postcode__c) : '';
                                        instAddr += r[0][0].Country__c ? (', ' + r[0][0].Country__c) : '';


                                        CS.Log.warn('***** Installation Address: ' + instAddr);
                                    }
                                });
                            });
                        }
                    });
                })
                .fail(function(error) {
                    CS.Log.error(error);
                });
            } 

            var asbestosIdentified= CS.getAttributeValue('Asbestos_Identified_0', 'String');//Yes~No
            var suspectMaterials=false;
            //check if new definition has been deployed
            try{
               var obj = CS.Service.config['Suspected_Materials_0'];
               if(obj){suspectMaterials=true;}
            }
            catch(err){
            }

            var tradingName="British Gas";
            var logo = "<img src='BG_logo_s.png' />";
            var templateName = TemplateType.notes.british;
            var appointmentId = CS.getAttributeValue('Appointment_Id_0');
            var opportunityId  = CS.getAttributeValue('CHI_Lead_Id_0');

            var suspectMaterialsTable;
            var showRads=actualRadiatorExistis();//true~false
            
            checkIfScottishPostcode().then(function(tradeName) { 
                console.log("tradename:"+tradeName)
                if(tradeName == 'Scottish Gas'){
                    templateName = TemplateType.notes.scottish;
                    tradingName="Scottish Gas";
                    logo = "<img src='SG_logo_s.png' />";
                }


            var constructedAddress = '',
                newline = '\n',
                delimiter = ', ';

            CS.Log.warn('Using template ' + templateName + ' for Installation Notes Form.');

            
            var arr=[
                {field:'Installer_Notes_Boiler_0',title:'Installer Notes - Boiler/Controls'},
                {field:'Installer_Notes_Flue_0',title:'Installer Notes - Flue'},
                {field:'Installer_Notes_GasWater_0',title:'Installer Notes - Gas Water'},
                {field:'Installer_Notes_Disruption_0', title:'Installer Notes - Disruption'},
                {field:'Installer_Notes_Special_Customer_Requirements_0', title:'Installer Notes - Special customer requirements (including details of any planned home improvement work)'}
            ];

            var str="<div id='installerNotes'>";
            for(var i=0; i<arr.length; i++){
                var notes = CS.getAttributeValue(arr[i]['field'],'String');
                if(notes){
                    notes=notes.trim();
                    str+="<h4>"+arr[i]['title']+"</h4>";
                    str+="<p class='notes'>"+addLineBreak(notes)+"</p>";
                }
            }
            str+="</div>";
            var allNotesString=str;

            var chiLeadNumberString = "";

            try{
                chiLeadNumberString = CS.Service.config["CHI_Lead_Number_0"].attr["cscfga__Display_Value__c"];
            }
            catch(err){
                chiLeadNumberString ="Unable to display CHI Lead Number";
            }


            var radiatorTableHtml='';
            if(showRads==true){radiatorTableHtml=createRadiatorTable();}
            
            
            //var asbestosNotes = '';
            var asbestosNotesStr='';
            var suspectMaterialsTable='';

            if(suspectMaterials==false && asbestosIdentified=="Yes"){
                //--This is the old asbestos process--// 
                    var str = "<table class='shadedTable' id='asbestosLocationsTable'>";
                    var i=0;
                     while(CS.Service.config['Asbestos_Location_'+i]){ 
                        var asbestosLocationString = "";
                        try {
                            asbestosLocationString = CS.Service.config["Asbestos_Location_"+i+":Asbestos_Location_0"].attr["cscfga__Display_Value__c"];
                        }
                        catch(err) {
                            asbestosLocationString = "--None--";
                        }
                    
                        str+="<tr><td><td>"+i+"</td><td>"+asbestosLocationString+"</td></tr>";
                        if(CS.Service.config['Asbestos_Location_'+i]){i++} else break;

                    } 
                    str+="</table>";
                    asbestosNotesStr=str;
            }

            //build the NEW suspect materials table
            if(suspectMaterials==true && asbestosIdentified=='Yes'){                
                var l = CS.getAttributeWrapper('Suspected_Materials_0').relatedProducts.length; 
                var str = "<table class='shadedTable'>";
                str+="<tr>"
                str+="<th>ID</th><th>Room</th><th>Type</th><th>Disturbed</th><th>Is sample required</th><th>Removal action</th>";
                str+="</tr>";
                for (var i=0, l; i < l; i++) {
                    //add a new row'
                    var def='Suspected_Materials_'+i;
                    console.log(def);
                    var css='';
                    if(CS.getAttributeValue(def+":SampleReq_0","String")=='PP26'){css="class='red'";}
                    var row="<tr "+css+">"
                    row+="<td>"+i+"</td>"
                    +"<td>"+CS.getAttributeValue(def+":Room_0","String")+"</td>"
                    +"<td>"+CS.getAttributeValue(def+":Type_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":Disturbed_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":SampleReq_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":Action_type_0","String")+"</td>"
                    +"</tr>";
                    str+=row;
                }
                str+="</table>";
                suspectMaterialsTable=str;
            }

            //line breaks 
            var ladderWork = '';
            if(CS.Service.config['Scaffold_Notes_0']){
                ladderWork = CS.getAttributeValue('Scaffold_Notes_0', 'String');
                ladderWork = addLineBreak(ladderWork);
            }
            else{ladderWork='--None--';}
           
            
            var systemChar = '';
            if(CS.Service.config['System_Characteristics_Notes_0']){
                 systemChar = CS.getAttributeValue('System_Characteristics_Notes_0', 'String');
                    systemChar = addLineBreak(systemChar);
            }
            else{systemChar='--None--';}
           
            var removalAssistance = '';
            if(CS.Service.config['Component_Removal_Notes_0']){
                removalAssistance = CS.getAttributeValue('Component_Removal_Notes_0', 'String');
                removalAssistance = addLineBreak(removalAssistance);
            }
            else{removalAssistance='--None--';}
            
            var workAreaRestriction = '';
            if(CS.Service.config['Work_Area_Restrictions_Notes_0']){
                workAreaRestriction = CS.getAttributeValue('Work_Area_Restrictions_Notes_0', 'String');
                workAreaRestriction = addLineBreak(workAreaRestriction);
            }
            else{workAreaRestriction='--None--';}
            
            
            var workAreaHazard = '';
            if(CS.Service.config['Work_Area_Hazards_Notes_0']){
                workAreaHazard = CS.getAttributeValue('Work_Area_Hazards_Notes_0', 'String');
                workAreaHazard = addLineBreak(workAreaHazard);
            }
            else{workAreaHazard='--None--';}
            
            var boilerDetailsTable ='';
            if(CS.Service.config['Boiler_0:Boiler_0']){
                if(CS.Service.config["Boiler_0"].relatedProducts.length>0){
                    boilerDetailsTable = getBoilerDetailsTable();
                }
            }

            //--check if a boiler IQ OR HIVE component requiring email has been added--//
            var connectedProductAdded='FALSE';
            for(var id in partsModelJS){
                //console.log(id);
                try{
                    var code=partsModelJS[id].parentPart.part.Part_Code__c;
                }
                catch(err){
                    var code='';
                }
                console.log(code)
                 //if(code=='PSLT1' || code=='PSLT2' || code=='PSLT3' || code=="PSLT4" || code=='PCBH1' || code=='PCBH2'){
                 // updated 15/07/19 by PD
                 if(code=='PSLT1' || code=='PSLT2' || code=='PSLT3' || code=="PSLT4"|| code=='PSLT49'|| code=='PSLT50' || code=='PSLT51' || code=='PSLT52' || code=='PSLT61' || code=='PSLT62' || code=='PSLT63' || code=='PCBH1' || code=='PCBH2'|| code=='PCBH4' || code=='PCBH5'){    
                    connectedProductAdded='TRUE';
                    break;
                }
            }

            function today(){
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();

                if(dd<10) {dd='0'+dd} 
                if(mm<10) {mm='0'+mm} 
                return dd+'/'+mm+'/'+yyyy;
            }

            var definitionName = CS.getAttributeValue("Definition_Name_0") ? CS.getAttributeValue("Definition_Name_0") : '';
            var jobTitle = CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") ? "Job Title: "+CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") : '';

            var jsonObject = {
                "AccessNotes" : workAreaRestriction,
                "AllNotes" : allNotesString,
                "asbestosIdentified" : asbestosIdentified,
                "asbestosNotesStr" : asbestosNotesStr,
                "asbestosSample": CS.getAttributeValue("Asbestos_Sample_0", "String"),
                "BoilerDetails" : boilerDetailsTable,
                "CHILeadNumber": CS.getAttributeValue("CHI_Lead_Number_0", "String"),
                "connectedEmail":CS.getAttributeValue('Boiler_0:Controls_0:Customer_Email_Address_2_0') || '?',
                "connectedProductAdded":connectedProductAdded,
                "CustomerArrange" : CS.getAttributeValue('Customer_to_Arrange_0', 'String') || '--None--',
                "customerName":CS.getAttributeValue('Customer_Name_0'),
                "customerAddress":instAddr,
                "productDefinition":definitionName,
                "EarthLocation" : CS.getAttributeValue('Earthing_Location_0', 'String') || '--None--',
                "EarthSystem" : CS.getAttributeValue('Earth_System_Type_0', 'String') || '--None--',
                "Flow" : CS.getAttributeValue('Boiler_0:Flow_Rate_0', 'String') || '--None--',
                "hsaName":quoteHsaName,
                "jobTitle":jobTitle,
                "LadderWork" : ladderWork,
                "logo" : logo,
                "Peb" : CS.getAttributeValue('Protective_Earth_Bonding_Required_0', 'String') || '--None--',
                "quoteReference":CS.getAttributeValue('Quote_Reference_0'),
                "Radiator" : radiatorTableHtml || '',
                "Rdc" : CS.getAttributeValue('RCD_0', 'String') || '--None--',
                "RemovalAssistance" : removalAssistance,
                "Scaffolding" : CS.getAttributeValue('Scaffolding_Required_0', 'String') || '--None--',
                "Seb" : CS.getAttributeValue('Supplementary_Bonding_Required_0', 'String') || '--None--',
                "SocketSee" : CS.getAttributeValue('Socket_and_See_reading_0', 'String') || '--None--',
                "suspectMaterials":suspectMaterialsTable,
                "SystemCharacter" : systemChar,
                "tradingName":tradingName,
                "VisibleEarth" : CS.getAttributeValue('Visible_Earth_0', 'String') || '--None--',
                "visitDate":today(),
                "Voelcb" : CS.getAttributeValue('Working_VOELCB_0', 'String') || '--None--',
                "WaterTestPressure" : CS.getAttributeValue('Boiler_0:Standing_Pressure_0', 'String') || '--None--',
                "WorkAreas" : workAreaHazard,
                "jobTitle":CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0", "String"),
                "definitionName":CS.getAttributeValue("Definition_Name_0", "String")
            };

            var jsonString = JSON.stringify(jsonObject);
            jsonString = replaceJsonCharacters(jsonString);

            CS.Log.warn('Calling the DSAPlugin...');
            
            cordova.exec(function(result){
                CS.Log.warn(result);
                if(typeof result === "string") result = JSON.parse(result);
                var installationFormSigned = result.signed,
                    installationFormPath = result.path;
                    
                CS.Log.warn('installationFormSigned: ' + installationFormSigned);
                CS.Log.warn('installationFormPath: ' + installationFormPath);
                
                //Added-2017
                if(CS.isCsaContext){
                    if((installationFormSigned ==true)||(installationFormSigned =='Yes')){
                        installationFormSigned = 1;
                    }
                    else{
                        installationFormSigned = 0;
                    }
                }
                //end

                CS.setAttributeValue('Installation_Form_Signed_0', installationFormSigned);
                CS.setAttributeValue('Installation_Form_Path_0', installationFormPath);
                
                //pdf fix
                var myPath = CS.getAttributeValue("Installation_Form_Path_0");

                var myNewPath = myPath.split("index.pdf")[0];
                
                myNewPath += "InstallationPdf1.pdf";
                
                                cordova.exec(
                                function(result){
                                   
                                    CS.Log.warn(result);
                
                                    var b64String = result;
                                    cordova.exec(
                                        function(result){
                                           
                                            CS.Log.warn(result);
                
                                            var myPath = CS.setAttributeValue("Installation_Form_Path_0", myNewPath);
                                            
                                        }, 
                                        function(e) { CS.Log.error(e);},
                                        
                                        "DSAFilePlugin", "dataToFile",[myNewPath, b64String]);
                                    
                                }, 
                                function(e) { CS.Log.error(e);},
                                
                                "DSAFilePlugin", "base64",[myPath]);
                //end pdf fix
            }, 
                function(e) { CS.Log.error(e);},
                    "DSAHTMLTemplatePlugin", "openTemplate",[templateName,jsonString,null,true,true]);
            });
            
        }
        else {
            installationTemplateOnlineGenerate(logoType);
            var logoType = 'BG';
             checkIfScottishPostcode().then(function(tradeName) { 
                if(tradeName == 'Scottish Gas'){
                    logoType = 'SG';
                    installationTemplateOnlineGenerate(logoType);
                }
                else{
                     logoType = 'BG';
                     installationTemplateOnlineGenerate(logoType);
                }
            });
        }

    };

    //generateHTML template
    window.generateHTMLTemplateWithoutSignature = function generateHTMLTemplateWithoutSignature(templateName,jsonString){
        cordova.exec(function(result){
                CS.Log.warn(result);
                if(typeof result === "string") result = JSON.parse(result);
                var templatePath = result.path;
            }, 

                function(e) { CS.Log.error(e);},
                    "DSAHTMLTemplatePlugin", "openTemplate",[templateName,jsonString,null,true,true]);
    }

    window.openCustomerConfirmationForm = function openCustomerConfirmationForm(templateName) {
        if(navigator.device) {

            var templateName = TemplateType.customerConfirmationForm.withgraphics;
            var templateNameBackup = TemplateType.customerConfirmationForm.withgraphics;
            
            if (isScottishPostcode()) {
                templateName = TemplateType.customerConfirmationForm.scottish;
            }


            toggleBtnCss('btn-customer-confirmation-form');

            CS.Log.warn('Using template ' + templateName + ' for Customer Confirmation Form.');


            var jsonObject = {
                "CreditIntermediaryName" : "",
                "BritishGasNewHeatingLimited" : "British Gas New Heating Limited",
                "ApplicationNumberOfLoan" : CS.getAttributeValue('Application_Number_0', 'String') || ''
            };

            var jsonString = JSON.stringify(jsonObject);
            jsonString = replaceJsonCharacters(jsonString);

            CS.Log.warn('Calling the DSAPlugin...');

            cordova.exec(function(result){
                
                CS.Log.warn(result);
                if(typeof result === "string") result = JSON.parse(result);
                var confirmationFormSigned = result.signed,
                    confirmationFormPath = result.path;
                    
                CS.Log.warn('confirmationFormSigned: ' + confirmationFormSigned);
                CS.Log.warn('confirmationFormPath: ' + confirmationFormPath);
                
                CS.setAttributeValue('Confirmation_Form_Signed_0', confirmationFormSigned);
                CS.setAttributeValue('Confirmation_Form_Path_0', confirmationFormPath);

            }, 

                function(e) { 
                    CS.Log.error(e);

                    cordova.exec(function(result){
                    //clearTimeout(timeoutVarId);
                    CS.Log.warn(result);
                    if(typeof result === "string") result = JSON.parse(result);
                    var confirmationFormSigned = result.signed,
                        confirmationFormPath = result.path;
                        
                    CS.Log.warn('confirmationFormSigned: ' + confirmationFormSigned);
                    CS.Log.warn('confirmationFormPath: ' + confirmationFormPath);
                    
                    CS.setAttributeValue('Confirmation_Form_Signed_0', confirmationFormSigned);
                    CS.setAttributeValue('Confirmation_Form_Path_0', confirmationFormPath);

                    }, 

                    function(e) { 
                    CS.Log.error(e);},
                    "DSAPDFPlugin", "openTemplateWithStyle",[templateNameBackup,jsonString,null,true,true]);


                },
                    "DSAPDFPlugin", "openTemplateWithStyle",[templateName,jsonString,null,true,true]);
        }
    };
    
    //Loan calculator
    window.openLoanCalculator = function openLoanCalculator() {
        if(navigator.device) {

            var templateName = 'LoanCalculator';

            var tradingName = 'British Gas';
            
            checkIfScottishPostcode().then(function(tradeName) { 
                if(tradeName == 'Scottish Gas') {
                tradingName = 'Scottish Gas';
                CS.Log.warn('Using scottish template: ' + templateName);
                }
                else{
                    tradingName = 'British Gas';
                }
                
                // need to pass a string instead of boolean
                var eligIFC = isEligibleForIFC() ? "TRUE" : "FALSE";
            
                var jsonObject = {
                    "deposit" : CS.getAttributeValue('Actual_Deposit_0', 'String') || '',
                    "installationCost" : CS.getAttributeValue('Total_Price_Payable_0', 'String') || '',
                    "tradingName" : tradingName,
                    "eligibleForInterestFreeCredit" : eligIFC
                };
    
                var jsonString = JSON.stringify(jsonObject);
                jsonString = replaceJsonCharacters(jsonString);

            

                cordova.exec(function(result){
                    
                    CS.Log.warn(result);
                    var currentTradeName = result.currentValues.tradingName;
                    CS.Log.warn('This is current trading name '+currentTradeName);
                    try{
                       var currentDeposit = result.currentValues.deposit;
                        CS.Log.warn('This is the actual deposit '+currentDeposit);
                        var parsedDeposit = parseFloat(currentDeposit);
                        if(CS.isCsaContext){
                            parsedDeposit = parseFloat(currentDeposit);
                        }
                        else{
                            parsedDeposit = currentDeposit;
                            
                        }

                        CS.setAttributeValue('Actual_Deposit_0', parsedDeposit);  // old product definition doesn't have that attribute, so we set Actual_Deposit_0 directly

                    }
                    catch(error){
                         CS.Log.warn('No deposit');
                    }
                }  , 
    
                    function(e) { 
                        CS.Log.error(e);},
                        "DSAHTMLTemplatePlugin", "openTemplate",[templateName,jsonString,null,true,true]);
                });
        }
    };


    window.populateFinanceTableInput = function populateFinanceTableInput() {

        //var amount = parseFloat(CS.getAttributeValue('Total_Price_Payable_0')); // {Total Price - Total Allowances}
         var amount = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0);


        var amountFormatted = amount.toFixed(2).replace(/./g, function(c, i, a) {
            return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
        });
        
        
        var ballonTotalPrice = CS.getAttributeValue('Total_Price_Payable_0') || '0';
        ballonTotalPrice = formatPriceComma(ballonTotalPrice);
        ballonTotalPrice = ballonTotalPrice.replace(/&pound;/g, "");
        
        var deposit = CS.getAttributeValue('Actual_Deposit_0') || '0';
        deposit = formatPriceComma(deposit);
        deposit = deposit.replace(/&pound;/g, "");
        
        var balanceOutstanding = CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c || '0';
        balanceOutstanding = formatPriceComma(balanceOutstanding);
        balanceOutstanding = balanceOutstanding.replace(/&pound;/g, "");
        
        var financeTableInput = {

            "waysToPayTotalAmount":'\u00A3' + ballonTotalPrice,
            "waysToPayDeposit":'\u00A3' + deposit,
            "waysToPayBalance":'\u00A3' + balanceOutstanding,
            "3_mmp":        '\u00A3' + monthlyPayment(amount,3),
            "3_tar":        '\u00A3' + totalAmountRepayable(amount,3),

            "5_mmp":        '\u00A3' + monthlyPayment(amount,5),
            "5_tar":        '\u00A3' + totalAmountRepayable(amount,5),

            "8_mmp":        '\u00A3' + monthlyPayment(amount,8),
            "8_tar":        '\u00A3' + totalAmountRepayable(amount,8),

            "10_mmp":       '\u00A3' + monthlyPayment(amount,10),
            "10_tar":       '\u00A3' + totalAmountRepayable(amount,10),

            "totalAmount":  '\u00A3' + amountFormatted
        };

        return financeTableInput;

    }


    /* Open Finance Illustration PDF */

    window.openFinanceIllustrationPDF = function openFinanceIllustrationPDF() {

       //var amount = parseFloat(CS.getAttributeValue('Total_Price_Payable_0')); // {Total Price - Total Allowances}
        //2016 - value based on deposit
        var amount = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0);


        var amountFormatted = amount.toFixed(2).replace(/./g, function(c, i, a) {
            return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
        });

        var ballonTotalPrice = CS.getAttributeValue('Total_Price_Payable_0') || '0';
        ballonTotalPrice = formatPriceComma(ballonTotalPrice);
        ballonTotalPrice = ballonTotalPrice.replace(/&pound;/g, "");
        
        var deposit = CS.getAttributeValue('Actual_Deposit_0') || '0';
        deposit = formatPriceComma(deposit);
        deposit = deposit.replace(/&pound;/g, "");
        
        var balanceOutstanding = CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c || '0';
        balanceOutstanding = formatPriceComma(balanceOutstanding);
        balanceOutstanding = balanceOutstanding.replace(/&pound;/g, "");

        var financeTableInput = {
            
            "waysToPayTotalAmount":'\u00A3' + ballonTotalPrice,
            "waysToPayDeposit":'\u00A3' + deposit,
            "waysToPayBalance":'\u00A3' + balanceOutstanding,

            "3_mmp":        '\u00A3' + monthlyPayment(amount,3),
            "3_tar":        '\u00A3' + totalAmountRepayable(amount,3),

            "5_mmp":        '\u00A3' + monthlyPayment(amount,5),
            "5_tar":        '\u00A3' + totalAmountRepayable(amount,5),

            "8_mmp":        '\u00A3' + monthlyPayment(amount,8),
            "8_tar":        '\u00A3' + totalAmountRepayable(amount,8),

            "10_mmp":       '\u00A3' + monthlyPayment(amount,10),
            "10_tar":       '\u00A3' + totalAmountRepayable(amount,10),

            "totalAmount":  '\u00A3' + amountFormatted
        };

        CS.Log.info('input for finance illustration:');
        CS.Log.info(financeTableInput);

        if(navigator.device) {
            openFinanceIllustrationPDFOffline(financeTableInput);
        } else {
            openFinanceIllustrationPDFOnline(financeTableInput);
        }
    };

    /* Prepare parameters and load Finance Illustration PDF template offline */

    window.openFinanceIllustrationPDFOffline = function openFinanceIllustrationPDFOffline(financeTableInput) {

        var jsonString = JSON.stringify(financeTableInput);

        var templateName = 'finance_template_BG';
        if (isScottishPostcode()) {
            templateName = 'finance_template_SG';
        }


        testStyleJsonFinance = {
             "waysToPayTotalAmount": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "waysToPayDeposit":     {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "waysToPayBalance":     {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
                "3_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "3_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "5_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "5_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "8_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "8_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "10_mmp": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },
            "10_tar": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                },

            "totalAmount": {"font-name" : "Avenir-Book",
                    "font-size" : "9",
                    "underline" : false
                }
            };  

            var styleJSONFinance = JSON.stringify(testStyleJsonFinance);
            styleJSONFinance = replaceJsonCharacters(styleJSONFinance);


        CS.Log.warn('Calling the DSA plugin openTemplate');


        var newVersionDepot = "previous";

        cordova.exec(function(r){newVersionDepot='newVersion'}, function(r){CS.Log.error(r)}, "DSAInfoPlugin", "appVersion");

        CS.Log.warn('VERSION0  ='+newVersionDepot);

           cordova.exec(function(result){
                //clearTimeout(timeoutVarId);
                CS.Log.warn(result);
                if (typeof result === "string") result = JSON.parse(result);
                var financeIllustrationPath = result.path;

                CS.Log.warn('VERSION3  ='+newVersionDepot);
                CS.Log.warn('financeIllustrationPath+++: ' + financeIllustrationPath);
                
                CS.setAttributeValue('Finance_Illustration_Path_0', financeIllustrationPath);

            }, 

                function(e) { CS.Log.error(e);
                        confirm("Finance illustration PDF is not available on this version of Depot");},
                    "DSAPDFPlugin", "openTemplateWithStyle",[templateName,jsonString,styleJSONFinance,true,true]); 
         
   
    };

// helper function for determining if the client is eligible for interest free credit

window.isEligibleForIFC = function() {
    
    var dateToTimeMillis = function(date) {
        var day = parseInt(date.substring(8, 10));
        var month = parseInt(date.substring(5, 7)) - 1; // minus 1 because Date() expects month to be 0-based for some reason
        var year = parseInt(date.substring(0, 4));
        
        return (new Date(year, month, day)).getTime();
    };
    
    // get the chi_lead_created_date
    var chi_lead_created_date = dateToTimeMillis(CS.getAttributeValue('CHI_Lead_Created_Date_0'));

    // get the quote creation date (or now())
    var quote_creation_date = Date.now();

    var date_start_ms = dateToTimeMillis(IFC_DATE_START);
    var date_end_ms = dateToTimeMillis(IFC_DATE_END);
    var date_final_ms = dateToTimeMillis(IFC_DATE_FINAL);
    
    // check if the chi_lead_created_date is less than End Date
    // check if the quote creation date is greater than Start Date
    // if former two conditions are satisfied, client is eligible
    
    //console.log("date_start_ms = " + date_start_ms);
    //console.log("date_end_ms = " + date_end_ms);
    //console.log("quote_creation_date = " + quote_creation_date);
    //console.log("chi_lead_created_date = " + chi_lead_created_date);
    return ( quote_creation_date >= date_start_ms &&
             quote_creation_date <= date_final_ms &&
         chi_lead_created_date <= date_end_ms);
}

//new quote
window.getQuoteData = function getQuoteData() {
    
        var appointmentId = CS.getAttributeValue('Appointment_Id_0');
    
        function getHeaderDataNew() {
        
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'iPad') {
    
                CS.Log.warn('***** Now calling SmartQuery for get Header Info...');
                
                // Prevent missing Opportunity from stopping pdf generation, split queries (retrieve inner join of Appointment with Opportunity)
                return CS.DB.smartQuery("SELECT {Appointment__c:_soup} FROM {Appointment__c} WHERE {Appointment__c:Id} = '" + appointmentId + "'").then(function(qr) {
                    return qr.getAll().then(function (results) {
                           
                        var params = {};
                        if (results.length > 0) {
                            CS.Log.warn('***** Appointment retrieved: ' + results.length);
                            CS.Log.warn(results[0][0]);
                            var appointment = results[0][0]; //Appointment will exist
                                
                            return CS.DB.smartQuery("SELECT {Opportunity:_soup} FROM {Opportunity} WHERE {Opportunity:Id} = '" + appointment.Opportunity__c + "'").then(function(qr) {
                                return qr.getAll().then(function (r) {
                                    params.app = appointment;
                                             
                                    params.opp = {}; 
                                    if (r && r.length > 0) {
                                        CS.Log.warn('***** Opportunity retrieved: ' + r.length);
                                        CS.Log.warn(r[0][0]);
                                        params.opp = r[0][0];
                                    }

                                    return Q.resolve(params);
                                });
                            });
                        } else {
                            CS.Log.warn('***** No Appointment retrieved');
                            return Q.resolve(params);
                        }
                    });
                })
                .then(function (params) {
                    return getPrimaryContactSmSt(params);
                })
                .fail(function(error) {
                    CS.Log.error(error);
                });

                function getPrimaryContactSmSt(result) {
                    CS.Log.warn('Getting primary contact from smartstore');
                    
                    var appointment = result.app, 
                        opportunity = result.opp;
                    CS.Log.warn('appointment: ' + appointment);
                    CS.Log.warn('opportunity: ' + opportunity);
                    
                    if ( appointment && (typeof appointment) == "string") {
                        appointment = JSON.parse(appointment);
                    }
                    if (opportunity && (typeof opportunity) == "string") {
                        opportunity = JSON.parse(opportunity);
                    }
                    
                    var header = {},
                        installationAddress = {
                            Name: '',
                            Street: '',
                            PostalCode: '',
                            Telephone: '',
                            Mobile: ''
                        },
                        billingAddress = {
                            Name: '',
                            Street: '',
                            PostalCode: '',
                            Telephone: '',
                            Mobile: ''
                        };

                    header.InstallationAddress = installationAddress;
                    header.BillingAddress = billingAddress;
                    header.QuoteNumber = CS.getAttributeValue('Quote_Reference_0');
                    header.Contact = '';
                    header.TransactionId = '';
                    
                    if (!_.isEmpty(appointment)) {
                        header.TransactionId = appointment.CHI_Lead_No__c ? ('' + appointment.CHI_Lead_No__c) : ''; //must be string
                        
                        

                        CS.Log.warn('TransactionId: ' + appointment.CHI_Lead_No__c);
                    }
                    
                    // if Opportunity has not been retrieved, do not proceed to retrieving primary contact
                    if (_.isEmpty(opportunity)) {
                        CS.Log.warn('Opportunity not retrieved.');
                        
                        // If the opportunity has not been retrieved populate with details from the attributes
                        var installAddress = CS.getAttributeValue('Installation_Address_0');
                        if(installAddress) {
                            var installAddressSplit = installAddress.split(',');
                            installationAddress.Street = installAddressSplit[0];
                            installationAddress.PostalCode = installAddressSplit[3];
                        }

                        var billAddress = returnBillingAddress();
                        if(billAddress) {
                            var billAddressSplit = billAddress.split(',');
                            var fullContactName = CS.getAttributeValue('Customer_Name_0') !== null ? CS.getAttributeValue('Customer_Name_0') : '';

                            installationAddress.Name = fullContactName;
                                
                            billingAddress.Name = fullContactName;
                            billingAddress.Street = billAddressSplit[0];
                            billingAddress.PostalCode = billAddressSplit[3];
                        }
                        return Q.resolve(header); // pass an empty object since the method expects a parameter    
                    } else {
                        installationAddress.Street = opportunity.Install_Address_Street__c ? opportunity.Install_Address_Street__c : '';
                        installationAddress.PostalCode = opportunity.Install_Postcode__c ? opportunity.Install_Postcode__c : '';
                        installationAddress.Telephone = opportunity.SC_Home_Phone__c ? opportunity.SC_Home_Phone__c : '';
                        installationAddress.Mobile = opportunity.SC_Mobile_Phone__c ? opportunity.SC_Mobile_Phone__c : '';
                    }
                    
                    var contactLink = opportunity.Contact_Link__c;
                    var contactId = contactLink.substring(contactLink.indexOf('/')+1);
                    contactId = contactId.substring(0, contactId.indexOf('/'));
                    if (!contactId || contactId.length < 15) {
                        CS.Log.warn('Contact id not retrieved.');
                        return Q.resolve(header); // pass an empty object since the method expects a parameter    
                    }
                    contactId = generate18CharId(contactId);
                    CS.Log.warn('***** Contact id to be queried: ' + contactId);
                    return CS.DSA.searchData('Contact', 'Id', contactId)
                        .then(function(results) {
                            CS.Log.warn('*** Contact retrieved: ');
                            CS.Log.warn(results);
                            
                            // Populate Contact related info
                            if (results && results.length > 0) {
                                if(typeof results == 'string'){
                                    results = JSON.parse(results)[0];
                                }
                                contact = results;
                                var fullContactName = (contact.Salutation || '') + ' ' + (contact.FirstName || '') + ' ' + (contact.LastName || '');
                                var billAddressSplit = returnBillingAddress().split(',');

                                installationAddress.Name = fullContactName;
                                
                                billingAddress.Name = fullContactName;
                                billingAddress.Street = billAddressSplit[0] ? billAddressSplit[0] : (contact.MailingStreet ? contact.MailingStreet : '');
                                billingAddress.PostalCode = billAddressSplit[3] ? billAddressSplit[3] : (contact.MailingPostalCode ? contact.MailingPostalCode : '');
                                billingAddress.Telephone = contact.Best_Phone__c ? contact.Best_Phone__c : '';
                                billingAddress.Mobile = contact.MobilePhone ? contact.MobilePhone : '';
                            } else {
                                 CS.Log.warn('Problem: No Contact record has been retrieved for contactId: ' + contactId);
                            }

                            return Q.resolve(header);
                        })
                        .then(function (header) {
                            // Get the quote employee details
                            var hsaId = CS.getAttributeValue('Assigned_To_Employee_0');
                            if(hsaId !== '') {
                                return CS.DB.smartQuery("SELECT {Employee__c:_soup} from {Employee__c} WHERE {Employee__c:Id} = '" + hsaId + "'").then(function(qr) { 
                                    return qr.getAll().then(function(results) {
                                        var assignedToEmployee = results[0][0];
                                        CS.Log.warn("Assigned to employee: ");
                                        CS.Log.warn(assignedToEmployee);
                                        
                                        var hsaName = assignedToEmployee.First_Name__c + ' ' + assignedToEmployee.Last_Name__c,
                                            hsaNumber = assignedToEmployee.Phone_No__c;
                                        quoteHsaName=hsaName;
                                        quoteHsaNum = hsaNumber;
                                        header.Contact = 'To discuss or accept your quotation please contact ' + hsaName + ' on ' + hsaNumber + ' or alternatively call us on 0333 202 9488 (Option 3)';
                                        return Q.resolve(header);
                                    });
                                });
                            } else {
                                return Q.resolve(header);    
                            }
                        })
                        .fail(function(error) {
                            CS.Log.error(error);
                            return Q.resolve(header); 
                        });
                }
    
            } 
        }
    
        function getSectionListNew() {
    
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'iPad') {
                CS.Log.warn('***** Now calling SmartQuery for get Section List Info...');
                
                return CS.DB.smartQuery("SELECT {CS_Template_Section_Header__c:_soup} FROM {CS_Template_Section_Header__c} ")
                    .then(function(qr) {
                        return qr.getAll().then(function(results) {
                            CS.Log.warn('Template header results');
                                
                            var resultList = [];
                            for (var i = 0; i < results.length; i++) {
                                resultList.push(results[i][0]);
                            }
                            CS.Log.warn(resultList);

                            return Q.resolve(resultList);
                        });
                    }).fail(function(error) {
                        CS.Log.error(error);
                    });
            }
        }
        
        if(navigator.device){
            Q.all([getHeaderDataNew(), getSectionListNew()]).then(function(result){
            CS.Log.warn('Q.all result:');
            CS.Log.warn(result[0]);
            CS.Log.warn(result[1]);
            var params = {
                headerData: result[0],
                allSections: result[1]    
            };

                return populateJsonObjectNew(params);
            })
            .fail(function(e) { 
                CS.Log.error(e);
            });
        }
        else{
            generateOnlineHTMLQuote();
        }
        
    
        /**
         * Used to create a json string to be sent for pdf quote generation.
         * @param {Object} header   an object containing custom header data retreived from server.
         */
        function populateJsonObjectNew(params) {

            var header = params.headerData;
            var allSectionList =  params.allSections;
            
            myAllSections = allSectionList;
            
            CS.Log.warn(header);
    
            CS.Log.warn('Populating quote object...');
    
            var quoteObject = {};
            // HEADER - remaining fields are here, no need for redundancy
    
            function toFullMonthDateNew(d){
                var monthNames = [ "January", "February", "March", "April", "May", "June",
                    "July", "August", "September", "October", "November", "December" ];   
                return monthNames[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
            }
    
            CS.Log.warn('Quote_Creation_Date_0: ' + CS.getAttributeValue('Quote_Creation_Date_0'));
            header.QuoteDate = toFullMonthDateNew(new Date(CS.getAttributeValue('Quote_Creation_Date_0')));
            CS.Log.warn('QuoteDate: ' + header.QuoteDate);
            
            header.TotalPricePayable = formatPrice(CS.getAttributeValue('Total_Price_Payable_0'));
            header.Deposit = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            header.DepositReference = '' + CS.getAttributeValue('Deposit_Receipt_Number_0');
            header.DepositPaidBy = CS.getAttributeValue('Payment_Type_0');
            
            var balance = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0); 
            header.Balance = formatPrice(balance);
            
            header.BalancePaidBy = CS.getAttributeValue('Payment_Option_0');
    
            quoteObject.Header = header;
    
            // customer needs
            var customerNeeds = "During the visit today, you expressed the following needs and requirements:";
            quoteObject.CustomerNeeds = customerNeeds;
    
            // ************** DETAILS ****************
            var details = {};
            details.Description = CS.getAttributeValue('Reason_for_Quotation_0');
            
            function addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList){
                var section = getSectionById(sectionId, sectionList); //find if section exists, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionId, sectionName);
                    sectionList.push(section);
                }
                section.Text = (section.Text === '' ? description : (section.Text + '\n' + description)) ;
                section.addToSubtotal(aggregatedPriceInclVAT);
            }
            
            function addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId) {
                var sectionLevel1 = getParentSection(sectionId, allSectionList); // get level 1 section id from all sections list
            
                var section = getSectionById(sectionLevel1.Id, sectionList); // check if a section with that id exists in sectionList, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionLevel1.Id, sectionLevel1.Name);
                    sectionList.push(section);                     
                }
                
                product = getSectionById(sectionId, section.Products); // find a lvl2 section (product) if exists within that section, otherwise create new lvl 2 section
                if (product === null) {
                    product = new Product(sectionId, sectionName);
                    section.addProduct(product);
                }
            
                // add the item as line item
                var lineItem = new LineItem(description, quantity, aggregatedPriceInclVAT, aggregatedPriceInclVAT, lineItemId);
                product.addLineItem(lineItem);
            }
                
            //new QUote development
            //quoteNewDevelopment
            function extractAssociatedParts(parent){
                 var aPList =[];
                 for (var key in partsModelJS) {
                    if(key == parent){
                        if (partsModelJS.hasOwnProperty(key)) {        
                            //if part
                            if(partsModelJS[key].isPart){
                                if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                                    CS.Log.warn('PART==');
                                    CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                        
                                    
                                    if(partsModelJS[key]['associatedParts'].length>0){
                                        console.log("Associated Parts");
                                        for(var aPart in partsModelJS[key]['associatedParts']){
                                            if(partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c']){
                        
                                                var parentSectionLevel= partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                                                var parentSectionName=partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                        
                                                var sectionId = partsModelJS[key]['associatedParts'][aPart]['part']['CS_Template_Section_Header__c'];
                        
                                                console.log('Part =='+partsModelJS[key]['associatedParts'][aPart]['part']['Description__c']+'  SKill=='+partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c']+'  Price=='+partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT']+' quantity=='+partsModelJS[key]['associatedParts'][aPart]['quantity']);
                                                var aPLI = new AssociatedPartLineItem(sectionId, 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Description__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Quote_Description__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['quantity'], 
                                                        parentSectionName, 
                                                        parentSectionLevel,
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Id']);
                        
                                                aPList.push(aPLI);
                                            }
                                        }
                                    }
                                    else{
                                        CS.Log.warn('No associated parts');
                                    }
                                    CS.Log.warn('----------');
                                }
                                
                        
                            }
                        
                            //if bundle
                            else{
                                if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                                    CS.Log.warn('BUNDLE==');
                                    CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                                    CS.Log.warn('----------');
                                }
                            }
                        }
                    } 
                }
                return aPList;
             }
            
            function iterateQuoteParts(){
                var partsList = [];
            
                for (var key in partsModelJS) {
                    if (partsModelJS.hasOwnProperty(key)) {        
                    //if part
                    if(partsModelJS[key].isPart){
                        if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                            CS.Log.warn('PART==');
                            CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                
                            var sectionId = partsModelJS[key]['parentPart']['part']['CS_Template_Section_Header__c'];
                            var isPart = partsModelJS[key].isPart;
                            var level = partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                            var sectionName = partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                            var partDescription = partsModelJS[key]['parentPart']['part']['Quote_Description__c'];
                            var price = partsModelJS[key]['parentPart']['priceVatIncl'];
                            var quantity = partsModelJS[key]['parentPart']['quantity'];
                            var associatedParts = extractAssociatedParts(key);
                            var lineItemId = partsModelJS[key]['parentPart']['part']['Id'];
                            var partItem = new PartQuoteItem(isPart, sectionId, level, sectionName, partDescription, price, quantity, associatedParts, lineItemId);
                                                
            
                            console.log(partItem);
            
                            partsList.push(partItem);
                        }   
                
                    }
                
                    //if bundle
                    else{
                        if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                            CS.Log.warn('BUNDLE==');
                            CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                            CS.Log.warn('----------');
                        }
                    }
                  }
                } 
            
                return partsList;
            }


            function addAssociatedPartsNewQuote(sectionList, allSectionList){
                var pL = iterateQuoteParts();
                    for(p in pL){
                        if(pL[p].associatedPartsList.length>0){
                            for(ap in pL[p].associatedPartsList){
                                console.log("In my Test=="+pL[p].associatedPartsList[ap].level);
                                if(pL[p].associatedPartsList[ap].level == SectionLevel1){
                                    console.log('+++++++++Adding level 1');
                                    addLevel1SectionNew(pL[p].associatedPartsList[ap].sectionId, pL[p].associatedPartsList[ap].sectionName, pL[p].associatedPartsList[ap].partDescription, pL[p].associatedPartsList[ap].price, sectionList);
                                }
                                if(pL[p].associatedPartsList[ap].level == SectionLevel2){
                                    console.log('++++++++Adding level 2');
                                    addLevel2SectionNew(pL[p].associatedPartsList[ap].sectionId, 
                                            pL[p].associatedPartsList[ap].sectionName, 
                                            pL[p].associatedPartsList[ap].partDescription, 
                                            pL[p].associatedPartsList[ap].price, 
                                            pL[p].associatedPartsList[ap].quantity, 
                                            sectionList, 
                                            allSectionList,
                                            pL[p].associatedPartsList[ap].lineItemId);
                                }
                            }
                        }
                    }
            }
            //---end quote New development
            //--end new quote development
                
                
            function isRadiatorAttributeNew(item) {
                var attRef = item.attRef;
                // this checks only the start of the string
                if(attRef.lastIndexOf(radiator, 0) === 0) {
                    if((attRef.indexOf(placeholder)>0) || (attRef.indexOf(actual)>0) || (attRef.indexOf(fittingBundle)>0)) {
                        return true;    
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
                
            function addRadiatorOrFittingBundleNew(item, radiatorMap, fittingBundleMap) {
                // get reference for map
                var attRef = item.attRef,
                    len = item.attRef.indexOf(":"),
                    index = attRef.substr(0, len);
                
                // add placeholders and actuals to radiator map
                // add fitting bundles to fitting bundle map
                if((attRef.indexOf(placeholder) > 0) || (attRef.indexOf(actual) > 0)) {
                    radiatorMap[index] = item;
                } else if(attRef.indexOf(fittingBundle) > 0) {
                    fittingBundleMap[index] = item;
                }
            }
            
            function addRadiatorsToSectionListNew(radiatorMap, fittingBundleMap, sectionList, allSectionList) {
                // iterate radiator map
                for (var attRef in radiatorMap) {
                    if (!radiatorMap.hasOwnProperty(attRef)) continue;
                    var rad = radiatorMap[attRef],
                        fittingBundle = fittingBundleMap[attRef];
            
                    // construct radiator and add to section list
                    if(!_.isEmpty(rad)) {
                        var sectionId = rad.parentPart.part.CS_Template_Section_Header__c,
                            sectionName = rad.parentPart.part.Section_Name__c ? rad.parentPart.part.Section_Name__c : '',
                            sectionLevel = rad.parentPart.part.Section_Level__c,
                            description = rad.parentPart.part.Quote_Description__c ? rad.parentPart.part.Quote_Description__c : (rad.parentPart.part.Description__c ? rad.parentPart.part.Description__c : (rad.parentPart.part.Name ? rad.parentPart.part.Name : '')),
                            aggregatedPriceInclVAT = (rad.aggregatedPriceInclVAT || rad.aggregatedPriceInclVAT === 0) ? rad.aggregatedPriceInclVAT : 0;

                        if(!_.isEmpty(fittingBundle)) {
                            CS.Log.warn('fitting bundle is not empty');
                            CS.Log.warn(fittingBundle);
                            // construct a description with fitting bundle
                            var fittingBundleName = fittingBundleNameMap[fittingBundle.parentBundle.Fitting_Pack__c];
                            description += ' (' + fittingBundleName + ')';
                            // add the fitting price to the radiator price
                            fittingBundlePrice = (fittingBundle.aggregatedPriceInclVAT || fittingBundle.aggregatedPriceInclVAT === 0) ? fittingBundle.aggregatedPriceInclVAT : 0;
                            aggregatedPriceInclVAT += fittingBundlePrice;
                        }

                        // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                        CS.Log.warn('Adding a radiator...');
                        if (sectionLevel === SectionLevel1) { 
                            addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                        } else if (sectionLevel === SectionLevel2) {
                            addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, 0);
                        }
                    }
                }
            }
            
            var SectionLevel1 = 'Level 1',
                SectionLevel2 = 'Level 2';
                
            var radiator = 'Radiator_',
                actual = 'Actual_Radiator_',
                placeholder = 'Placeholder_',
                fittingBundle = 'Fitting_Bundle_';
            var radiatorMap = {},
                fittingBundleMap = {};
                fittingBundleNameMap = {
                    'New location in same room': 'new fix',
                    'Same place, different size': 'replacement',
                    'Same place, same size': 'replacement',
                    'New installation': 'new installation'
                };
    
            var sectionList = [];
            
            
            //iterate through build parts model and create a product structure
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id)) continue;
                var item = partsModelJS[id];
    
                if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
    
                    var quantity = 1;
                    var description = '';
                    var aggregatedPriceInclVAT = (item.aggregatedPriceInclVAT || item.aggregatedPriceInclVAT === 0) ? item.aggregatedPriceInclVAT : 0;
                    var parentPartPrice = 0;
    
                    if (item.isBundle) {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                        quantity = parseInt(item.attLastQuantity, 10) ? parseInt(item.attLastQuantity, 10) : 1;
    
                    } else {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                        quantity = parseInt(item.parentPart.quantity, 10) ? parseInt(item.parentPart.quantity, 10) : 1;
                        parentPartPrice = (item.parentPart.priceVatIncl || item.parentPart.priceVatIncl === 0) ? item.parentPart.priceVatIncl : 0;
                    }
    
                    var section = null;
                    var product = null;
    
                    if(isRadiatorAttributeNew(item)) {
                        addRadiatorOrFittingBundleNew(item, radiatorMap, fittingBundleMap);
                    } else {
                        if (item.isPart && !(item.isMultilookup)) {
                            CS.Log.warn('Adding a part...');
                            //get section id, name, level
                            var sectionId = item.parentPart.part.CS_Template_Section_Header__c;
                            var sectionName = item.parentPart.part.Section_Name__c ? item.parentPart.part.Section_Name__c : '';
                            var sectionLevel = item.parentPart.part.Section_Level__c;
                            var lineItemId = item.parentPart.part.Id;
                            
                            // Change made to check the .parentPart.part.Show_Parts__c flag, if the flag is true, show associated parts along with the parent part
                           
                            var showAssociatedParts = item.parentPart.part.Show_Parts__c;
                            if(showAssociatedParts) {
                                // add the parent part
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionNew(sectionId, sectionName, description, parentPartPrice, sectionList);        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionNew(sectionId, sectionName, description, parentPartPrice, quantity, sectionList, allSectionList, lineItemId);
                                }
                                // add the associated parts
                                CS.Log.warn('Adding associated parts- NOT ++++++&&&&&...');
                                /* removed---new Quote Development
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    var aPdescription = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var aPquantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var aPpriceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                                    
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1SectionNew(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), sectionList); 
                                        CS.Log.warn('Adding associated part in Level1 ==='+aPdescription);
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2SectionNew(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), aPquantity, sectionList, allSectionList);
                                        CS.Log.warn('Adding associated part in Level2 ==='+aPdescription);
                                    }
                                }
                                */
                            } else {
                                // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                            
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId);
                                }
                            }
                            
                            
                            
                        } 
                        else if (item.isBundle) {
                            CS.Log.warn('Adding a bundle...');
                            // Change made to check the .parentBundle.Show_Parts__c flag, if the flag is true, show parts instead of bundle
                            var showParts = item.parentBundle.Show_Parts__c;
                            if (showParts) {
                                // flag is set to true, iterate through all associated parts of the bundle
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    
                                    var description = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var quantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var priceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                        
                                    var sectionId = associatedPart.part.CS_Template_Section_Header__c;
                                    var sectionName = associatedPart.part.Section_Name__c ? associatedPart.part.Section_Name__c : '';
                                    var sectionLevel = associatedPart.part.Section_Level__c;
                                    var lineItemId = associatedPart.part.Id
                        
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1SectionNew(sectionId, sectionName, description, (priceVatIncl * quantity), sectionList); 
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2SectionNew(sectionId, sectionName, description, (priceVatIncl * quantity), quantity, sectionList, allSectionList, lineItemId);
                                    }
                                }      
                            } else {
                                var sectionId = item.parentBundle.CS_Template_Section_Header__c;
                                var sectionName = item.parentBundle.Section_Name__c ? item.parentBundle.Section_Name__c : '';
                                var sectionLevel = item.parentBundle.Section_Level__c;
                                var lineItemId = item.parentBundle.id;
                                
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList); 
                        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, 1, sectionList, allSectionList, lineItemId);
                                }
                            }
                        }        
                    }
                }
            }
            
            // add the constructed radiators
            addRadiatorsToSectionListNew(radiatorMap, fittingBundleMap, sectionList, allSectionList);
    
            mySectionList = sectionList;
            //new quote test dev
            addAssociatedPartsNewQuote(sectionList, allSectionList);
            //end new quote test
            
            
            details.Sections = sectionList;
            quoteObject.Details = details;
    
            // FOOTER
            var footer = {
                TotalGrossPrice: formatPrice(CS.getAttributeValue('Gross_Price_incl_VAT_0')),
                NetContractPrice: formatPrice(CS.getAttributeValue('Total_Price_Payable_0'))
            };
    
            CS.Log.warn('Adding discounts...');
            var discountList = new Product(null, 'Discounts:');
            //iterate through applied allowances and add them as line items 
            for (var c = 1; c <= 6; c++) {
                var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                    allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                    allowanceQuantity = '',
                    allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                    allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                    allowanceId = CS.getAttributeValue('Allowance' + c + '_0');

                    if (allowanceDescription == '') {
                        allowanceDescription = allowanceName;
                    }
                // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
                if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                    var lineItem = new LineItem(allowanceDescription, allowanceQuantity, allowancePrice, allowancePrice, allowanceId);
                    discountList.addLineItem(lineItem);
                }
            }
            footer.Discounts = discountList;
    
            quoteObject.Footer = footer;
    
            applySequencesAndDisplayPricesNew(allSectionList, quoteObject);
        }
    
        function applySequencesAndDisplayPricesNew(resultList, quoteObject) {
    
            CS.Log.warn('Applying sequences...');
            CS.Log.warn('All Section list: ');
            CS.Log.warn(resultList);
    
            var sectionList = quoteObject.Details.Sections;
            CS.Log.warn(sectionList);
            
            // iterate through all of the sections and apply sequences
            for(var i=0; i<sectionList.length; i++){
                var section = sectionList[i];
                CS.Log.warn('Going through section: ' + section.Header + ' with id: ' + section.Id);
    
                var actualSection = getSectionById(section.Id, resultList);
    
                CS.Log.warn('Actual section: ');
                CS.Log.warn(actualSection);
                section.Sequence__c = actualSection.Sequence__c;
                
                var numOfProducts = section.Products ? section.Products.length : 0;
                CS.Log.warn('Num of section products: ' + numOfProducts);
    
                if (numOfProducts > 0){
                    // iterate through all of the products, apply sequences
                    for(var j=0; j<numOfProducts; j++){
                        var product = section.Products[j];
                        CS.Log.warn('Iterating through product:');
                        CS.Log.warn(product);
    
                        var actualProduct = getSectionById(product.Id, resultList);
                        CS.Log.warn('Actual product is: ');
                        CS.Log.warn(actualProduct);
    
                        product.Sequence__c = actualProduct.Sequence__c;
    
                        CS.Log.warn('Item totals flag: ' + actualProduct.Show_item_totals__c + ' and group totals flag: ' + actualProduct.Show_group_totals__c);
                        // clean line item totals and quantities if necessary for lvl 2 sections
                        if (!actualProduct.Show_item_totals__c) {
                            CS.Log.warn('Cleared line item totals and quantities.');
                            product.clearLineItemTotalsAndQuantities();
                        }
                        if (!actualProduct.Show_group_totals__c) {
                            CS.Log.warn('Cleared subtotals.');
                            product.SubTotal = '';
                            CS.Log.warn(product);
                        }
                    }
                    // sort lvl 2 sections if there are any
                    section.Products.sort(function(a, b) {
                        return a.Sequence__c - b.Sequence__c;
                    });
                    
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                    
                } else {
                    // show concise lvl 1 if it doesnt have lvl 2 sections
                    CS.Log.warn('Section does not have lvl 2 sections.');
                    section.concise();
                    CS.Log.warn(section);
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                }                
            }
    
            sectionList.sort(function(a, b) {
                return a.Sequence__c - b.Sequence__c;
            });
            
            // add a message for low cost quotes (e.g. for low cost pricebooks)
            var isLowCostQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_LowCost ? true : false;
            CS.Log.warn('Is the quote a low cost quote: ' + isLowCostQuote);
            if(isLowCostQuote) {
                var lowCostSection = new Section('noId', 'Quotation details', 0);
                lowCostSection.Text = 'The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.';
                lowCostSection.concise(); // remove the unnecessary section fields
                lowCostSection.SubTotal = ''; // remove the subtotal
                if(sectionList.length > 0) {
                    sectionList.unshift(lowCostSection);
                } else {
                    sectionList.push(lowCostSection);
                }
            }
            
            quoteObject.Details.Sections = sectionList;
            
            createJsonFromObjectNew(quoteObject);
        }
    
        function createJsonFromObjectNew(quoteObject) {
    
            CS.Log.warn('Creating json from object...');
            
            quoteObjNewTest=quoteObject;
            var quoteJSON = JSON.stringify(quoteObject);
            quoteJSON = replaceJsonCharacters(quoteJSON);
            openNewQuoteForm();
        }
    };
    
    window.formatPriceComma = function formatPriceComma(value){
        var formatted = "&pound;0.00";
        if(value){
            value = value.toString();
            if(value.length>0){
                console.log('********VALUE =='+value);
                if(value.indexOf('&pound;')!=-1){
                    formatted = value.split('&pound;')[1];
                }
                else{
                    formatted = value;
                }
                
                formatted = parseFloat(formatted);
                formatted = formatted.toFixed(2).replace(/./g, function(c, i, a) {
                        return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
                 });
                 
                 formatted = '&pound;'+ formatted;
                }
            }
            
         return formatted;
    }
    
   
     //NEW QUOTE
    window.openNewQuoteForm = function openNewQuoteForm() {
        
         var associatedPartsList =[];
         var company="British Gas";
         var transactionId = ""+CS.Service.config["CHI_Lead_Number_0"].attr.cscfga__Display_Value__c;
         var quoteNumber = ""+quoteObjNewTest.Header.QuoteNumber;
         var quoteDate = quoteObjNewTest.Header.QuoteDate;
         var depositReceiptNumber = quoteObjNewTest.Header.DepositReference;
         var allowancesApplied =  allowancesApplied();
         var billingPostcode = CS.Service.config["Billing_Postcode_0"].attr.cscfga__Display_Value__c;
         var billingCounty =CS.Service.config["Billing_County_0"].attr.cscfga__Display_Value__c;
         var billingStreet =CS.Service.config["Billing_Street_0"].attr.cscfga__Display_Value__c;
         var installationAddress = "";
         var customerName = quoteObjNewTest.Header.InstallationAddress.Name;
         var hsaName = quoteHsaName;
         var hsaContactNumber = quoteHsaNum ||"";
         var ballonTotalPrice = formatPriceComma(CS.getAttributeValue('Total_Price_Payable_0'));
         var ballonDiscount = quoteObjNewTest.Footer.Discounts.SubTotal;
         var depositPaidBy = CS.Service.config["Payment_Type_0"].attr.cscfga__Display_Value__c;
         var deposit = formatPriceComma(CS.getAttributeValue('Actual_Deposit_0'));
         var balanceOutstanding=formatPriceComma(CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c);
         var showEnergyTerms = '';
         var showGiftCardTerms = '';
         var templateName = "NewQuote";   
         var isSmallCommercialQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_SmallCommercial ? true : false;
         CS.Log.warn('Is the quote a Small Commercial quote: ' + isSmallCommercialQuote);
         if(isSmallCommercialQuote) {
             templateName = "SmallCommercialQuote";
         }
         
         if(CS.isCsaContext){
             balanceOutstanding='&pound;'+CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c;
         }
        
        var allowanceEmail = CS.getAttributeValue("Contact_Email_0") ? CS.getAttributeValue("Contact_Email_0") : "";
        var vatRate = CS.getAttributeValue("Allowance_VAT_0");//20
        var totalNetPrice = CS.getAttributeValue("Total_Net_Price_0") ? CS.getAttributeValue("Total_Net_Price_0") : 0;
        var totalAllowancesNet = CS.getAttributeValue('Total_Allowance_Value_0') ? (CS.getAttributeValue('Total_Allowance_Value_0')/(1+vatRate/100)).toFixed(2) : 0;
         
         totalNetPrice = formatPriceComma(totalNetPrice-totalAllowancesNet);

         console.log(totalNetPrice);

         
         
         var balanceToBePaidBy = CS.Service.config["Payment_Option_0"].attr.cscfga__Display_Value__c;
         //var amount = parseFloat(CS.getAttributeValue('Total_Price_Payable_0')); // {Total Price - Total Allowances}
         
          //2016 - value based on deposit
        var amount = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0);

         
        if(CS.isCsaContext){
            amount = (CS.getAttributeValue('Total_Price_Payable_0') ? CS.getAttributeValue('Total_Price_Payable_0') : 0) - (CS.getAttributeValue('Actual_Deposit_0') ? CS.getAttributeValue('Actual_Deposit_0') : 0);
         
        }
         
         var amountFormatted;
         if(CS.isCsaContext){
             amountFormatted = '&pound;'+ amount.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
         }
         else{
             amountFormatted = amount.toFixed(2).replace(/./g, function(c, i, a) {
                return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
         });
         }

        /*
        ballonTotalPrice = parseFloat(CS.getAttributeValue('Total_Price_Payable_0'));
        ballonTotalPrice = ballonTotalPrice.toFixed(2).replace(/./g, function(c, i, a) {
                return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
         });
         
         ballonTotalPrice = '&pound;'+ballonTotalPrice;
         */
         
         var mmp_2 = '&pound;' +monthlyPayment(amount,2);
         var mmp_3 = '&pound;'+monthlyPayment(amount,3);
         var mmp_5 = '&pound;'+monthlyPayment(amount,5);
         var mmp_8 = '&pound;'+monthlyPayment(amount,8);
         var mmp_10 = '&pound;'+monthlyPayment(amount,10);
         var tar_2 = '&pound;' + totalAmountRepayable(amount,2);
         var tar_3 = '&pound;'+totalAmountRepayable(amount,3);
         var tar_5 = '&pound;'+totalAmountRepayable(amount,5);
         var tar_8 = '&pound;'+totalAmountRepayable(amount,8);
         var tar_10 = '&pound;'+totalAmountRepayable(amount,10);
            
            
            
        function allowancesApplied(){
            CS.Log.warn('NEW++++++++ALLOWANCES++++++');
            //returns string of allowances actually applied to the quote

            var applied={};
             //iterate through applied allowances and add them as line items 
            for (var c = 1; c <= 6; c++) {
                var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                    allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                    allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                    allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                    allowanceId = CS.getAttributeValue('Allowance' + c + '_0');
    
                    if (allowanceDescription == '') {
                        allowanceDescription = allowanceName;
                    }
                // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
                if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                    applied[allowanceDescription]=allowancePrice;
                }
            }
            if(jQuery.isEmptyObject(applied)){
                return "No allowances applied";
            }else{
                var total=0;
                var str="<table style='width:100%;' id='allowances-table'>";
                jQuery.each(applied, function(key, value) {
                    str+="<tr><td>"+key+"</td><td style='font-weight: normal;'>"+formatPriceComma(value)+"</td></tr>";
                    total+=value;
                });
                //add a footer row
                str+="<tr class='boldText'><td>Total Allowances</td><td>"+formatPriceComma(CS.Service.config["Total_Allowance_Value_0"].attr.cscfga__Value__c)+"</td></tr>";
                str+="</table>";
    
                return str;
            }
        }
    
        var logoPng = "<img class='bgLogo' src='BG_logo_s.png' />";
         var yourQuote = 'Your British Gas Quotation';
         //if(isScottishPostcode()){
          
            if(navigator.device) {
                checkIfScottishPostcode().then(function(tradeName) { 
                    if(tradeName == 'Scottish Gas'){
                     logoPng = "<img class='bgLogo' src='SG_logo_s.png' />";
                     yourQuote = "Your Scottish Gas Quotation";
                     company="Scottish Gas";
                    }
                //new line 
                var sectionPrices="<p class='pageHeading' id='summaryTableHeading'>"+yourQuote+"</p>";
               
                //changed this line to sectionPrices+=
                 //var sectionPrices="<table style='table-layout: fixed; height:500px;width:470px;' id='summary-table' class='leftRadius'>";
                sectionPrices+="<table style='table-layout: auto; height:470px;width:470px;' id='summary-table' class='leftRadius'>";
               
                //add companyName
                 //removed this line and added as tag above table
                //sectionPrices += "<tr style='height:50px;'><th colspan='2'>"+ yourQuote +"</th></tr>";
                 
                //add customer title and last name, quote reference
                 sectionPrices += "<tr><td id='tbl-custName'>"+ customerName +"</td><td>"+quoteNumber+"</td></tr>";
                //sectionPrices += "<td id='tbl-quoteNo'>"+ quoteNumber +"</td></tr>";
                //sectionPrices += "<td id='tbl-quoteNo'></td></tr>";
                
                var firstLoop = false;
                
                //Section price summary
                for(sec in quoteObjNewTest.Details.Sections){

                     var totalPrice=0;
                
                    
                        if(quoteObjNewTest.Details.Sections[sec].Products){
                            for(pr in quoteObjNewTest.Details.Sections[sec].Products){
                                for(lin in quoteObjNewTest.Details.Sections[sec].Products[pr].LineItems){
                                    totalPrice+=parseFloat(quoteObjNewTest.Details.Sections[sec].Products[pr].LineItems[lin].Price.split(';')[1]);
                                                }
                                
                            }
                            
                        }
                        else{
                            totalPrice = quoteObjNewTest.Details.Sections[sec].SubTotal.split(';')[1];
                
                        }
                    if(quoteObjNewTest.Details.Sections[sec].Header){
                        
                        if(firstLoop == false){
                            firstLoop = true;
                            //IC added additional class and name attribute
                            sectionPrices+="<tr class='topBorder'><td class='summary-section capitalize' name='trim'>"+quoteObjNewTest.Details.Sections[sec].Header+"</td>";
                            sectionPrices+="<td class='section-price'>"+formatPriceComma(totalPrice)+"</td></tr>"
                        }
                        else{
                            //IC added additional class and name attribute
                            sectionPrices+="<tr><td class='summary-section capitalize' name='trim'>"+quoteObjNewTest.Details.Sections[sec].Header+"</td>";
                            sectionPrices+="<td class='section-price'>"+formatPriceComma(totalPrice)+"</td></tr>"
                        }
                    }
                }
                sectionPrices+="<tr><td class='summary-section total-gross'>Total gross price (inc. VAT)</td>";
                sectionPrices+="<td class='section-price'>"+formatPriceComma(CS.Service.config["Gross_Price_incl_VAT_0"].attr.cscfga__Value__c)+"</td></tr>";
                
                //allowances applied
                function addAllowancesToSection(){
                    var allowancePart =[];
                    var energyRef = CS.getAttributeValue("Energy_Account_Ref_0") ? CS.getAttributeValue("Energy_Account_Ref_0") : '';
                    //var energyCodes = ['E1','E2','E3'];
                
                    for(var i =1; i<7; i++){
                        var allRef = "Allowance"+i+"_0";
                        var allowanceCode = CS.getAttributeFieldValue(allRef, 'Code');
                        var isApplied = CS.getAttributeFieldValue(allRef, 'Is_Applied');
                        var allowanceAmount = CS.getAttributeFieldValue(allRef, 'ActualAmount');
                        var allowanceCode = CS.getAttributeFieldValue(allRef, 'Code');
                        var requiresBillingRef = CS.getAttributeFieldValue(allRef,'requiresBillingRef');
                        var requiresEmail = CS.getAttributeFieldValue(allRef,'requiresEmail');
                        console.log(allowanceCode);

                        var text = CS.getAttributeFieldValue(allRef, 'AllowanceDescription') ? CS.getAttributeFieldValue(allRef, 'AllowanceDescription') : CS.getAttributeFieldValue(allRef, 'AllowanceName');

            if((isApplied == 'TRUE') && (CS.getAttributeValue(allRef)) &&(CS.getAttributeValue(allRef)!="")){
                if(requiresBillingRef.toLowerCase()=='true'){
                    text+=" ref: "+energyRef;
                    showEnergyTerms = 'true';
                }
                if(requiresEmail.toLowerCase()=='true'){
                    showGiftCardTerms = 'true';
                }
                
                var allAmount = formatPriceComma(allowanceAmount);
                var allowanceRow ="<tr><td style='padding-top:0;padding-bottom:0;' class='allowance-label'>"+ text+"</td><td style='padding-top:0;padding-bottom:0;' class='allowance-value'>" + allAmount+ "</td></tr>";
                allowancePart.push(allowanceRow);
            }
            else{
                var allowanceRow ="<tr><td>&nbsp;</td></tr>";
                allowancePart.push(allowanceRow);
            }   
                    }
                    
                    return allowancePart;
                }
                
                
                function allowancesExists(){
                     var allowanceExists = false;
                     for(var ind =1; ind<7; ind++){
                        var allRef = "Allowance"+ind+"_0";
                        if((CS.Service.config[allRef].attributeFields["Is_Applied"].cscfga__Value__c == 'TRUE') && (CS.getAttributeValue(allRef)) &&(CS.getAttributeValue(allRef)!="")){
                            allowanceExists = true;
                        }
                     }
                     
                     return allowanceExists;
                }
                var allAllowances = addAllowancesToSection();
                
                var allowanceExists = allowancesExists();
                //if(allAllowances.length>0){
                if(allowanceExists==true){
                    sectionPrices+="<tr><td colspan='2' style='height: 200px; width:470px; padding: 0px 0px; border-width: 0px;'><table style='table-layout: fixed; max-height: 200px; min-width: 470px; border-collapse: collapse; border-spacing: 0;'>";
                    sectionPrices +="<tr><td style='padding-top:0;padding-bottom:0;' class='boldText slate'>Our offers for you</td><td class='section-price'></td></tr>";
                    for(a in allAllowances){
                        sectionPrices +=allAllowances[a];
                        
                    }
                    sectionPrices+="</table></td></tr>";
                }
                else{
                    //sectionPrices +="<tr><td class='summary-section boldText'>&nbsp;</td><td class='section-price'></td></tr>";
                    sectionPrices+="<tr><td colspan='2' style='height: 200px; width:100%; padding: 0px 0px; border-width: 0px;'><table style='table-layout: fixed; max-height: 200px; min-width: 470px; border-collapse: collapse; border-spacing: 0;'>";
                    for(a in allAllowances){
                        sectionPrices +=allAllowances[a];
                        
                    }
                     sectionPrices+="</table></td></tr>";
                }
                
                
                //total discount
                if(allowanceExists==true){
                    sectionPrices+="<tr><td class='discount-total boldText'>Total discount</td><td class='section-total boldText'>"+formatPriceComma(CS.Service.config["Total_Allowance_Value_0"].attr.cscfga__Value__c)+"</td></tr>";
                }
                else{
                    sectionPrices+="<tr><td class='discount-total boldText'>&nbsp;</td><td class='section-total boldText'></td></tr>";
                }
                
                //Total Net Price (inc VAT)
                if(isSmallCommercialQuote){
                    sectionPrices+="<tr class='topBorder'><td class='total-net boldText'>Total price (exc. VAT)<p style='font-size:small'>VAT may be charged at various rates</p></td>";
                    sectionPrices+="<td class='section-total boldText'>"+totalNetPrice+"</td></tr>";

                    sectionPrices+="<tr><td class='total-net boldText'>Total price (inc. VAT)</td>";
                    sectionPrices+="<td class='section-total boldText'>"+formatPriceComma(CS.Service.config["Total_Price_Payable_0"].attr.cscfga__Value__c)+"</td></tr>";
                }else{
                    sectionPrices+="<tr class='topBorder'><td class='total-net boldText'>Total net price (inc. VAT)</td>";
                    sectionPrices+="<td class='section-total boldText'>"+formatPriceComma(CS.Service.config["Total_Price_Payable_0"].attr.cscfga__Value__c)+"</td></tr>";
                }

                sectionPrices+="</table>";
    
    
                CS.Log.warn("Section prices ===   "+sectionPrices);
                //Breakdown table
                var quoteBreakDownTable="";
                
                
                quoteBreakDownTable+="<table id='breakdown-table'>";
                 for(j=0;j<quoteObjNewTest.Details.Sections.length;j++){
                    quoteBreakDownTable+="<tr><td colspan='3' class='Level1'>"+quoteObjNewTest.Details.Sections[j].Header+"</td></tr>";
                    
                    if(quoteObjNewTest.Details.Sections[j].Products!=undefined){
                        
                        for(i=0;i<quoteObjNewTest.Details.Sections[j].Products.length;i++){
                            CS.Log.warn("Section"+j+" Product="+quoteObjNewTest.Details.Sections[j].Products[i].Description);
                            quoteBreakDownTable += "<tr><td colspan='3' class='Level2'>"+quoteObjNewTest.Details.Sections[j].Products[i].Description+"</td></tr>";
                            if(quoteObjNewTest.Details.Sections[j].Products[i].LineItems!=undefined){
                                CS.Log.warn("Section"+j+" Header="+quoteObjNewTest.Details.Sections[j].Header);
                                
                                
                                
                                
                                if(quoteObjNewTest.Details.Sections[j].Products[i].Description.toLowerCase().indexOf('radiators and valves')!=-1){
                                    var myParts = partsModelJS;
                                    var radValves = [];
                                    for (var key in myParts) {
                                      if (myParts.hasOwnProperty(key)) {
                                        //aggregate radiator and valve price
                                        //if as placeholder
                                        if(key.indexOf('Placeholder_0')!=-1){
                                            var indexKey = key.split(':')[0];
                                            var valveKey = indexKey+':'+'Radiator_Valve_0';
                                    
                                            var fittingBundleKey = indexKey+':'+'Fitting_Bundle_0';;
                                            var valveExists = false;
                                    
                                            var radV = {};
                                    
                                            var category = myParts[key]['parentPart']['part']['Radiator_Category__c'];
                                            var placeholderPrice = myParts[key]['aggregatedPriceInclVAT'];
                                    
                                            radV.price = placeholderPrice;
                                            radV.category = category;
                                    
                                            for (var key1 in myParts) {
                                                if(key1==valveKey){
                                                    valveExists = true;
                                                    radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                    radV.incValve = 'inc. valves';
                                    
                                                }
                                                if(key1==fittingBundleKey){
                                                    //summarize prices
                                                    radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                }
                                            }
                                            if(!valveExists){
                                                radV.incValve = '';     }
                                    
                                            radValves.push(radV);
                                        }
                                        
                                        
                                        //if not a placeholder
                                        //actual radiator 1
                                        if(key.indexOf('Actual_Radiator_1_0')!=-1){
                                        
                                            var indexKey = key.split(':')[0];
                                            var valveKey = indexKey+':'+'Radiator_Valve_0';
                                    
                                            var fittingBundleKey = indexKey+':'+'Fitting_Bundle_0';;
                                            var valveExists = false;
                                    
                                            var radV = {};
                                    
                                            var category = myParts[key]['parentPart']['part']['Radiator_Category__c'];
                                            var placeholderPrice = myParts[key]['aggregatedPriceInclVAT'];
                                    
                                            radV.price = placeholderPrice;
                                            radV.category = category;
                                    
                                            for (var key1 in myParts) {
                                                if(key1==valveKey){
                                                    valveExists = true;
                                                    radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                    radV.incValve = 'inc. valves';
                                    
                                                }
                                                if(key1==fittingBundleKey){
                                                    //summarize prices
                                                    radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                }
                                            }
                                            if(!valveExists){
                                                radV.incValve = '';     }
                                    
                                            radValves.push(radV);
                                        }
                                        //
                                        
                                            if((key.substring(0,15)=='Actual_Radiator')&&(key.indexOf(':Radiator_0')!=-1)){
                                                    CS.Log.warn('Working here!='+key);
                                                    var indexKey = key.split(':')[0];
                                                    var valveKey = indexKey+':'+'Radiator_Valve_0';
                                            
                                                    var fittingBundleKey = indexKey+':'+'Fitting_Bundle_0';;
                                                    var valveExists = false;
                                            
                                                    var radV = {};
                                            
                                                    var category = myParts[key]['parentPart']['part']['Radiator_Category__c'];
                                                    var placeholderPrice = myParts[key]['aggregatedPriceInclVAT'];
                                            
                                                    radV.price = placeholderPrice;
                                                    radV.category = category;
                                                    
                                                    for (var key1 in myParts) {
                                                        if(key1==valveKey){
                                                            valveExists = true;
                                                            radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                            radV.incValve = 'inc. valves';
                                            
                                                        }
                                                        CS.Log.warn('Working here!2'+key);
                                                        if(key1==fittingBundleKey){
                                                            //summarize prices
                                                            radV.price = radV.price + myParts[key1]['aggregatedPriceInclVAT'];
                                                        }
                                                    }
                                                    if(!valveExists){
                                                        radV.incValve = '';
                                                    }
                                                    CS.Log.warn('Working here!3'+key);
                                                    radValves.push(radV);
                                                }
                                        //
                                        
                                      }
                                        
                                    }
                                    var alreadyAggregated = [];
                                    for(k=0;k<radValves.length;k++){
                                        
                                        var radiatorLineItem = {};
                                        radiatorLineItem.description = radValves[k].category;
                                        
                                        switch(radValves[k].category) {
                                            case 'L':
                                                radiatorLineItem.description = 'Large';
                                                radiatorLineItem.sequence = 3;
                                                break;
                                            case 'S':
                                                radiatorLineItem.description = 'Small';
                                                radiatorLineItem.sequence = 1;
                                                break;
                                             case 'XL':
                                                radiatorLineItem.description = 'Extra Large';
                                                radiatorLineItem.sequence = 4;
                                                break;
                                            case 'M':
                                                radiatorLineItem.description = 'Medium';
                                                radiatorLineItem.sequence = 2;
                                                break;
                                            case 'LST':
                                                radiatorLineItem.description = 'Low Surface Temp';
                                                radiatorLineItem.sequence = 5;
                                                break;
                                             case 'Towel Warmer':
                                                radiatorLineItem.description = 'Towel Warmer';
                                                radiatorLineItem.sequence = 6;
                                                break;
                                            case 'Designer':
                                                radiatorLineItem.description = 'Designer';
                                                radiatorLineItem.sequence = 7;
                                                break;
                                            default:
                                                radiatorLineItem.description = '';
                                                radiatorLineItem.sequence = 1;
                                        }
                                        radiatorLineItem.quantity = 1;
                                        radiatorLineItem.price = parseFloat(radValves[k].price);
                                        radiatorLineItem.incValve = radValves[k].incValve;
                                        var existsItem=false;
                                        for(ii=0; ii<alreadyAggregated.length;ii++){
                                            //if((alreadyAggregated[ii].description == radiatorLineItem.description)&&(alreadyAggregated[ii].incValve == radiatorLineItem.incValve)){
                                            if(alreadyAggregated[ii].description == radiatorLineItem.description){
                                                alreadyAggregated[ii].quantity = alreadyAggregated[ii].quantity+1;
                                                alreadyAggregated[ii].price = alreadyAggregated[ii].price+ radiatorLineItem.price;
                                                alreadyAggregated[ii].sequence = alreadyAggregated[ii].sequence;
                                                existsItem = true;
                                            }
                                        }
                                        
                                        if(!existsItem){
                                            alreadyAggregated.push(radiatorLineItem);
                                        }
                                    }
                                    
                                    //ORDERING rads based on categories
                                    alreadyAggregated.sort(function(a, b){
                                     return a.sequence-b.sequence;
                                    });
                                    
                                    for(ii=0; ii<alreadyAggregated.length;ii++){
                                        
                                        CS.Log.warn('****RADS--');
                                        CS.Log.warn(alreadyAggregated);
                                        
                                        //var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPrice(alreadyAggregated[ii].price)+"</span></div>";
                                        var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPriceComma(alreadyAggregated[ii].price)+"</span></div>";
                                        
                                        var quantityItem = alreadyAggregated[ii].quantity;
                                        
                                        if(alreadyAggregated[ii].quantity == '1'){
                                            quantityItem = ' ';
                                        }
                                        else{
                                            quantityItem = '( x'+alreadyAggregated[ii].quantity+')';
                                        }
                                        //quoteBreakDownTable +="<tr><td class='cellDesc'>Install "+alreadyAggregated[ii].description.replace(/\\r\\n/g, "<br/>")+' Radiator '+'<span style="font-style: italic">'+alreadyAggregated[ii].incValve+"</span>"+"</td><td style='white-space: nowrap;' class='cellQty'>(x "+alreadyAggregated[ii].quantity+")</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                                    
                                        //quoteBreakDownTable +="<tr><td class='cellDesc'>Install "+alreadyAggregated[ii].description.replace(/\\r\\n/g, "<br/>")+' Radiator '+'<span style="font-style: italic">'+alreadyAggregated[ii].incValve+"</span>"+"</td><td style='white-space: nowrap;' class='cellQty'>"+quantityItem+"</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                                    
                                        quoteBreakDownTable +="<tr><td class='cellDesc'>Install "+alreadyAggregated[ii].description.replace(/\\r\\n/g, "<br/>")+' Radiator '+"</td><td style='white-space: nowrap;' class='cellQty'>"+quantityItem+"</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                                    
                                        
                                    }
                                   
                                   //add shower radiator parts as allowance-label
                                    
                                    for (var key in myParts) {
                                          if (myParts.hasOwnProperty(key)) {
                                                if((key.indexOf('Manual_Radiator_Valve_')!=-1)||((key.indexOf('Actual_Radiator_')==-1) &&(key.indexOf('Placeholder_')==-1)&&(key.indexOf('Radiator_Valve_')==-1))){
                                                    if(myParts[key]['parentPart']){
                                                        if(myParts[key]['parentPart']['part']){
                                                          
                                                          if(myParts[key]['parentPart']['part']['Section_Name__c'] && myParts[key]['parentPart']['part']['Section_Level__c']) {
                                                            
                                                            if((myParts[key]['parentPart']['part']['Section_Name__c']=='Radiators and Valves') && (myParts[key]['parentPart']['part']['Section_Level__c']=='Level 2')){
                                                            
                                                                var quantityItemSt = '';
                                                                        
                                                                if(myParts[key]['parentPart']['quantity'] == '1'){
                                                                    quantityItemSt = ' ';
                                                                }
                                                                else{
                                                                    quantityItemSt = '( x'+myParts[key]['parentPart']['quantity']+')';
                                                                }
                                                                
                                                                //price fix - 28-7-2016
                                                                //var priceItemSt="<div class='price-wrapper'>"+"<span class='price'>"+formatPriceComma(myParts[key]['parentPart']['priceVatIncl'])+"</span></div>";
                                                                var priceItemSt="<div class='price-wrapper'>"+"<span class='price'>"+formatPriceComma(myParts[key]['parentPart']['priceVatIncl'] * myParts[key]['parentPart']['quantity'])+"</span></div>";
                                                              
                                                              
                                                                quoteBreakDownTable +="<tr><td class='cellDesc'>"+myParts[key]['parentPart']['part']['Quote_Description__c'].replace(/\\r\\n/g, "<br/>")+"</td><td style='white-space: nowrap;' class='cellQty'>"+quantityItemSt+"</td><td class='cellPrice'>"+priceItemSt+"</td></tr>";
                                    
                                                            }
                                    
                                                            
                                                          }                 
                                                          
                                                              
                                                        }
                                                        
                                                    }
                                                
                                              }
                                              
                                          }
                                      }
    
                                }
                                else{
                                    for(k=0;k<quoteObjNewTest.Details.Sections[j].Products[i].LineItems.length;k++){
                                         CS.Log.warn("Section"+j+" Product="+quoteObjNewTest.Details.Sections[j].Products[i].Description+" LineItem="+quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Description);
                                        //var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPrice(parseFloat(quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Total.split(';')[1]))+"</span></div>";
                                        var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPriceComma(quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Total)+"</span></div>";
                                        
                                        var quantityItem = quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Quantity;
                                        if(quantityItem == '(x 1)'){
                                            quantityItem=" ";
                                        }
                                        //quoteBreakDownTable += "<tr><td class='cellDesc'>"+quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Description.replace(/\\r\\n/g, "<br/>")+"</td><td style='white-space: nowrap;' class='cellQty'>"+quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Quantity+"</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                                        
                                        quoteBreakDownTable += "<tr><td class='cellDesc'>"+quoteObjNewTest.Details.Sections[j].Products[i].LineItems[k].Description.replace(/\\r\\n/g, "<br/>")+"</td><td style='white-space: nowrap;' class='cellQty'>"+quantityItem+"</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                                       
                                    }
                                }
                            }
                            else{
                                 CS.Log.warn("Section"+j+" Product="+quoteObjNewTest.Details.Sections[j].Products[i].Description+" LineItem=NO");
                            }
                        }
                        
                         
                    }
                    else{
                        //var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPrice(parseFloat(quoteObjNewTest.Details.Sections[j].SubTotal.split(';')[1]))+"</span></div>";
                        var priceItem="<div class='price-wrapper'>"+"<span class='price'>"+formatPriceComma(quoteObjNewTest.Details.Sections[j].SubTotal)+"</span></div>";
                        
                        //quoteBreakDownTable+="<tr><td class='cellDesc'>"+quoteObjNewTest.Details.Sections[j].Text.replace(/\\r\\n/g, "<br/>")+"</td><td style='white-space: nowrap;' class='cellQty'>(x1)</td><td class='cellPrice'>"+priceItem+"</td></tr>";
                        quoteBreakDownTable+="<tr><td class='cellDesc'>"+quoteObjNewTest.Details.Sections[j].Text.replace(/\\r\\n/g, "<br/>")+"</td><td style='white-space: nowrap;' class='cellQty'> </td><td class='cellPrice'>"+priceItem+"</td></tr>";
                        
                        
                            CS.Log.warn("**Section"+j+" Header="+quoteObjNewTest.Details.Sections[j].Header);
                            CS.Log.warn("Section"+j+" Product=NO");
                            
                             
                    }
                
                }
                quoteBreakDownTable+=addBoilerPlusReason();
                quoteBreakDownTable+="</table>";
              
               
                //Installation address
                installationAddress="<p>"+quoteObjNewTest.Header.InstallationAddress.Street+"</p>";
                installationAddress += "<p>"+quoteObjNewTest.Header.InstallationAddress.PostalCode+"</p>";
                
                var dearCustomer = "<h3>Dear "+customerName+"</h3>";
                
                
                function getPaymentDetails(totalPricePayable, deposit, depositReceiptNumber,depositPaidBy, balance, balanceToBePaidBy){
                 
                    var htmlResult = ""
                    
                    htmlResult+="<h4>Payment</h4>";
                    //IC updated set to sentence case
                    htmlResult+="<p>Total price payable: <span id='totalNetPrice'>"+totalPricePayable+"</span></p>"; 
                    
                    htmlResult+="<p>Deposit:<span id='deposit'>"+deposit+"</span></p>";
                    htmlResult+="<p>Deposit number:<span id='depositReceiptNumber'>"+depositReceiptNumber+"</span></p>"; 
                    htmlResult+="<p>Deposit paid by:<span id='depositPaidBy'>"+depositPaidBy+"</span></p>"; 
                    htmlResult+="<p>Balance:<span id='balanceOutstanding'>"+balance+"</span></p>"; 
                    htmlResult+="<p>Balance to be paid by: <span id='balanceToBePaidBy'>"+balanceToBePaidBy+"</span></p>"; 
                    
                    return htmlResult;
                }
                
            
                function getFooterContacts(hsaName, hsaContactNumber, quoteReference){
                    //IC updated removed colon
                    var str="<p style='font-size:85%'>"
                    +"To accept this quote, the simplest way is to go online via our portal&#42;, "
                    +"to discuss it further or make any changes please contact <span id='hsaName'>"+hsaName+"</span> on <span id='hsaContactNumber'>"+hsaContactNumber+"</span>"
                    +" or alternatively call us on 0333 202 9488. (Option 3)</p>";
                    return str;
                }
               var paymentDetails = getPaymentDetails(ballonTotalPrice,deposit,depositReceiptNumber,depositPaidBy,balanceOutstanding, balanceToBePaidBy);
               
               var footerContactsDetails = getFooterContacts(hsaName, hsaContactNumber, quoteNumber);
               
               var eligibleForInterestFree = isEligibleForIFC() ? "TRUE" : "";
               var definitionName = CS.getAttributeValue("Definition_Name_0") ? CS.getAttributeValue("Definition_Name_0") : '';
               var jobTitle = CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") ? "Role: "+CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") : '';
               var portalURL = CS.getAttributeValue("Portal_URL_0") ? encodeURI(CS.getAttributeValue("Portal_URL_0")) : '';
               var gasApplianceWarranty = partCodeExistsInPartsModelJS('P10006');
               var netPayableBelowThousand = CS.getAttributeValue('Total_Price_Payable_0') < 1000 ? "TRUE" : "";
               
               var jsonObject = { 
                    "logo":logoPng,
                   "logoPng":logoPng,
                    "logoPng2":logoPng,
                    "logoPng3":logoPng,
                    "logoPng4":logoPng,
                    "transactionId":transactionId,
                    "quoteNumber":quoteNumber,
                    "quoteDate":quoteDate,
                    "depositReceiptNumber":depositReceiptNumber,
                    "allowancesApplied":allowancesApplied,
                    "billingPostcode":billingPostcode,
                    "billingCounty":billingCounty,
                    "billingStreet":billingStreet,
                    "installationAddress":installationAddress,
                    "customerName":customerName,
                    "hsaName":hsaName,
                    "hsaContactNumber":hsaContactNumber,
                    "sectionPrices":sectionPrices,
                    "ballonTotalPrice":ballonTotalPrice,
                    "totalNETPrice":totalNetPrice,
                    "breakdownQuoteTable":quoteBreakDownTable,
                    "deposit":deposit,
                    "totalNetPrice":ballonTotalPrice,
                    "balanceToBePaidBy":balanceToBePaidBy,
                    "balanceOutstanding":balanceOutstanding,
                    "depositPaidBy":depositPaidBy,
                    "quoteRef":quoteNumber,
                    "quoteRef2":quoteNumber,
                    "mmp_2":mmp_2,
                    "mmp_3":mmp_3,
                    "mmp_5":mmp_5,
                    "mmp_8":mmp_8,
                    "mmp_10":mmp_10,
                    "tar_2":tar_2,
                    "tar_3":tar_3,
                    "tar_5":tar_5,
                    "tar_8":tar_8,
                    "tar_10":tar_10,
                    "waysToPayTotalAmount":ballonTotalPrice,
                    "waysToPayDeposit":deposit,
                    "waysToPayBalance":balanceOutstanding,
                    "minMonthlyTotal":mmp_10,
                    "illustrationDeposit":deposit,
                    "illustrationTotal":ballonTotalPrice,
                    "illustrationLoanAmount":balanceOutstanding,
                    "illustrationBalance":balanceOutstanding,
                    "paymentDetails":paymentDetails,
                    "footerContactsDetails":footerContactsDetails,
                    "company":company,
                    "company1":company,
                    "company2":company,
                    "tradingName1":tradeName,
                    "tradingName2":tradeName,
                    "eligibleForInterestFree": eligibleForInterestFree,
                    "productDefinition":definitionName,
                    "jobTitle":jobTitle,
                    "showEnergyTerms":showEnergyTerms,
                    "showGiftCardTerms":showGiftCardTerms,
                    "allowanceEmail":allowanceEmail,
                    "portalURL":portalURL,
                    "gasApplianceWarranty":gasApplianceWarranty,
                    "netPayableBelowThousand":netPayableBelowThousand

                }
                
                 // mutate the existing json object by transforming all values to string
                _.each(jsonObject, function(value, key, obj) { obj[key] = '' + value; });
                
                var jsonString = JSON.stringify(jsonObject);
                
                CS.Log.warn("WHOLE JSON ===   "+jsonString);
                
                jsonString = replaceJsonCharacters(jsonString);
                jsonString = jsonString.replace(/\\r\\n/g, '<br/>');
    
                CS.Log.warn('Calling the DSAPlugin++++...');

            
            
                cordova.exec(function(result){
                    CS.Log.warn(result);
                    CS.Log.warn('Working!!!!!');
                    
                    //new quote signed path
                    var newQuoteSigned = result.signed;
                    
                     if(newQuoteSigned == true){
                        newQuoteSigned = 1;
                    }
                    else{
                        newQuoteSigned = 0;
                    }
                    
                    var newQuotePath = result.path;
                    CS.Log.warn('NEW QUOTE SIGNED='+newQuoteSigned+ "   NEW QUOTE PATH="+newQuotePath);
                    CS.setAttributeValue('Pdf_Signed_0', newQuoteSigned);
                    CS.setAttributeValue('Pdf_Path_0', newQuotePath);
                    
                    var myPath = CS.getAttributeValue("Pdf_Path_0");

                    var myNewPath = myPath.split("index.pdf")[0];
                    
                    myNewPath += "NewQuote1.pdf";
                
                    cordova.exec(
                    function(result){
                       
                        CS.Log.warn(result);
    
                        var b64String = result;
                        cordova.exec(
                            function(result){
                               
                                CS.Log.warn(result);
    
                                var myPath = CS.setAttributeValue("Pdf_Path_0", myNewPath);
                                
                            }, 
                            function(e) { CS.Log.error(e);},
                            
                            "DSAFilePlugin", "dataToFile",[myNewPath, b64String]);
                        
                    }, 
                    function(e) { CS.Log.error(e);},
                    
                    "DSAFilePlugin", "base64",[myPath]);
                    //end new quote signed path
                }, 
    
                    function(e) { CS.Log.error(e);},
                        "DSAHTMLTemplatePlugin", "openTemplate",[templateName,jsonString,null,true,true]);
            });   
    
            }
    
             else{
                CS.Log.warn("Not available online");
            }
    
        };

//--END



    /* Prepare parameters and load Finance Illustration PDF template online */

    window.openFinanceIllustrationPDFOnline = function openFinanceIllustrationPDFOnline(financeTableInput) {
        
        jQuery('#btn-finance-illustration-pdf').attr('disabled', 'disabled');
        
        var templateURL = document.getElementById('CS_finance_template_BG_URL').value;
        var templateDivSelector = templateURL + ' #CS_finance_template_BG';
        
        if (navigator.appName == 'Microsoft Internet Explorer' ||  !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv 11/)) || jQuery.browser.msie == 1) {
            templateURL = document.getElementById('CS_finance_template_BG_URL_JPG').value;
            templateDivSelector = templateURL + ' #CS_finance_template_BG_JPG';
        }

        if (isScottishPostcode()) {
            templateURL = document.getElementById('CS_finance_template_SG_URL').value;
            templateDivSelector = templateURL + ' #CS_finance_template_SG';
        }

        CS.Log.info(templateDivSelector);

        //jQuery('<div id="tmp" style="display:none"></div>').appendTo('body');
        jQuery('<div id="tmp"></div>').appendTo('body');

        jQuery('#tmp').load(templateDivSelector, function(result, status) {

            var doc = new jsPDF('p', 'mm', [297, 210]);
            
            var base64PNGImageString = jQuery("#CS_finance_template_BG").attr("src");
            if (isScottishPostcode()) {
                base64PNGImageString = jQuery("#CS_finance_template_SG").attr("src");
            }

            if (navigator.appName == 'Microsoft Internet Explorer' ||  !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv 11/)) || jQuery.browser.msie == 1) {
                CS.Log.warn('adding base64 encode JPEG image');
                doc.addImage(base64PNGImageString, 'png', 0, 0, 210, 297, undefined, 'slow');
            } else {
                doc.addImage(base64PNGImageString, 'png', 0, 0, 210, 297, undefined, 'slow');
            }
            
            doc.setFontSize(8);

            doc.text(79, 115, financeTableInput["3_mmp"]);
            doc.text(79, 122.5, financeTableInput["3_tar"]);

            doc.text(111, 115, financeTableInput["5_mmp"]);
            doc.text(111, 122.5, financeTableInput["5_tar"]);

            doc.text(143, 115, financeTableInput["8_mmp"]);
            doc.text(143, 122.5, financeTableInput["8_tar"]);

            doc.text(175, 115, financeTableInput["10_mmp"]);
            doc.text(175, 122.5, financeTableInput["10_tar"]);

            doc.text(155.5, 136.5, financeTableInput["totalAmount"]);

            //doc.save('Finance Illustration.pdf');

            if (navigator.appName == 'Microsoft Internet Explorer' ||  !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv 11/)) || jQuery.browser.msie == 1) {

                var content = btoa(doc.output());

                UISupport.AttachPdfReturnId(
                    CS.params.linkedId,
                    'Finance Illustration BG' + Math.random().toString(36).replace(/[^a-z]+/g, '') + '.pdf',
                    content,
                    function(result, event) {
                        if(event.status) {
                            CS.Log.warn(result);
                            window.open('/servlet/servlet.FileDownload?file=' + result);
                            jQuery('#btn-finance-illustration-pdf').removeAttr('disabled');
                        }
                    }
                );
            } else {
                doc.output('dataurlnewwindow');
                jQuery('#btn-finance-illustration-pdf').removeAttr('disabled');
            }
        });
    };

// Offline
    function monthlyPayment(amount,term) {
        var monthlyPayment = parseFloat(Math.round(amount / 24.0)).toFixed(2);
        var numOfMonths = parseInt(12, 10);
        var annualInterestRate = 0.149;
        //var annualInterestRate = 0.099;
        var monthlyInterestRate = parseFloat((Math.pow((1 + annualInterestRate), (1/12)) - 1).toFixed(7));
        
        // IFC special case
        var value1 = amount;
        var value3 = 24;
        
        if (term > 2) {
            var value2 = Math.pow((1 + monthlyInterestRate), -1 * numOfMonths * term);
            value1 = parseFloat(amount * monthlyInterestRate);
            value3 = parseFloat(1 - value2);
        }

        monthlyPayment = parseFloat(value1 / value3).toFixed(2);

        CS.Log.info("monthlyPayment: " + monthlyPayment);

        monthlyPayment = monthlyPayment.replace(/./g, function(c, i, a) {
            return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
        });
        

        return monthlyPayment;
    }

    function totalAmountRepayable(amount,term) {
        var monthlyPayment = parseFloat(Math.round(amount / 24.0)).toFixed(2);
        var numOfMonths = parseInt(12, 10);
        var annualInterestRate = 0.149;
        //var annualInterestRate = 0.099;
        var monthlyInterestRate = parseFloat((Math.pow((1 + annualInterestRate), (1/12)) - 1).toFixed(7));
        
        // IFC special case
        var value1 = amount;
        var value3 = 24;
        
        if (term > 2) {
            var value2 = Math.pow((1 + monthlyInterestRate), -1 * numOfMonths * term);
            value1 = parseFloat(amount * monthlyInterestRate);
            value3 = parseFloat(1 - value2);
        }

        var monthlyPayment = parseFloat(value1 / value3).toFixed(2);

        var financeTerm = parseInt(term, 10);

        //var totalAmountPayable = parseFloat(monthlyPayment * numOfMonths * financeTerm).toFixed(2);

        totalAmountPayable = parseFloat(monthlyPayment * numOfMonths * financeTerm).toFixed(0);
        CS.Log.info("totalAmountPayable: " + totalAmountPayable);

        totalAmountPayable = totalAmountPayable.replace(/./g, function(c, i, a) {
            return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
        });


        return totalAmountPayable;
    }
    
    /**
     * Check whether the provided postcode is Scottish.
     * @param  {String}  postcode
     * @return {Boolean}          Return whether the provided postcode is Scottish.
     */
    function isScottishPostcode() {
        var salesRegion = CS.getAttributeValue('Geographic_Region_0');
        return salesRegion === 'Scotland';
    }
    
    /**
     * Replaces the special characters inside json strings.
     * @param  {String} jsonString
     * @return {String}            Returns the string with replaces characters.
     */
    function replaceJsonCharacters(jsonString) {
        jsonString = jsonString.split('&amp;').join('&');
        jsonString = jsonString.split('&pound;').join('\u00A3');
        return jsonString;
    }

    function returnBillingAddress() {

        function isNotEmptyOrWhitespace(str) {
           if(str === undefined) return false;
           return !(str.length === 0 || !str.trim());
        }
    
        // if any of the billing address fields are not empty, use values from those fields
        var street = CS.getAttributeValue('Billing_Street_0'),
            city = CS.getAttributeValue('Billing_City_0'),
            county = CS.getAttributeValue('Billing_County_0'),
            postcode = CS.getAttributeValue('Billing_Postcode_0'),
            country = CS.getAttributeValue('Billing_Country_0');
    
        var existingAddress = CS.getAttributeValue('Customer_Address_0').split(',');
        existingAddress[0] = isNotEmptyOrWhitespace(street) ? street : existingAddress[0];
        existingAddress[1] = isNotEmptyOrWhitespace(city) ? city : existingAddress[1];
        existingAddress[2] = isNotEmptyOrWhitespace(county) ? county : existingAddress[2];
        existingAddress[3] = isNotEmptyOrWhitespace(postcode) ? postcode : existingAddress[3];
        existingAddress[4] = isNotEmptyOrWhitespace(country) ? country : existingAddress[4];
        return existingAddress.join(',');
    }

    window.openBarclaysApplication = function openBarclaysApplication() {
        var oppId = CS.getAttributeValue('CHI_Lead_Id_0', 'String');
        var barclaysUrl = "/apex/BarclaysFinanceApplication?oppId=" + oppId;
        if(navigator.device) {

        } else {
            window.open(barclaysUrl);
        }
    };
    
    //new online quote - under development - do not deploy into Production
    //new quote
window.getOnlineQuoteData = function getOnlineQuoteData() {
    
    var appointmentId = CS.getAttributeValue('Appointment_Id_0');

    function getHeaderDataOnline() {
        
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == 'Laptop') {
                var deferred = Q.defer();
                CS.Log.warn('Getting header data...');
    
                UISupport.getHeaderData(
                    appointmentId,
                    function(result, event) {
                        if (event.status) {
    
                            var header = {};
                            header.Contact = result.Assigned_To_Name__c ? result.Assigned_To_Name__c : '';
                            header.QuoteNumber = result.CHI_Lead_No__c ? result.CHI_Lead_No__c : '';
    
                            var installationAddress = {};
                            installationAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                            installationAddress.Street = result.Opportunity__r.Install_Address_Street__c ? result.Opportunity__r.Install_Address_Street__c : '';
                            installationAddress.PostalCode = result.Opportunity__r.Install_Postcode__c ? result.Opportunity__r.Install_Postcode__c : '';
                            installationAddress.Telephone = result.Opportunity__r.SC_Home_Phone__c ? result.Opportunity__r.SC_Home_Phone__c : '';
                            installationAddress.Mobile = result.Opportunity__r.SC_Mobile_Phone__c ? result.Opportunity__r.SC_Mobile_Phone__c : '';
    
                            var billingAddress = {};
                            billingAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                            billingAddress.Street = result.Opportunity__r.Account.Primary_Contact__r.MailingStreet ? result.Opportunity__r.Account.Primary_Contact__r.MailingStreet : '';
                            billingAddress.PostalCode = result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ? result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode : '';
                            billingAddress.Telephone = result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c ? result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c : '';
                            billingAddress.Mobile = result.Opportunity__r.Account.Primary_Contact__r.MobilePhone ? result.Opportunity__r.Account.Primary_Contact__r.MobilePhone : '';
    
                            header.InstallationAddress = installationAddress;
                            header.BillingAddress = billingAddress;

                            deferred.resolve(header);
                        } else {
                            deferred.reject('Event failed');
                        }
                    }
                );
                return deferred.promise;
            }
        }

    function getSectionListOnline() {

        var device = (navigator.device ? 'iPad' : 'Laptop');
        if (device == 'Laptop') {
            var deferred = Q.defer();

                UISupport.getAllSections(
                    function(result, event) {
                        if (event.status) {

                            deferred.resolve(result);
                        } else {
                            deferred.reject('Event failed');
                        }
                    }
                );
                return deferred.promise; 
        }
    }
    
    Q.all([getHeaderDataOnline(), getSectionListOnline()]).then(function(result){
        CS.Log.warn('Q.all result:');
        CS.Log.warn(result[0]);
        CS.Log.warn(result[1]);
        var params = {
            headerData: result[0],
            allSections: result[1]    
        };

        return populateJsonObjectOnline(params);
    })
    .fail(function(e) { 
        CS.Log.error(e);
    });
    

    /**
     * Used to create a json string to be sent for pdf quote generation.
     * @param {Object} header   an object containing custom header data retreived from server.
     */
    function populateJsonObjectOnline(params) {

        var header = params.headerData;
        var allSectionList =  params.allSections;
        
        myAllSections = allSectionList;
        
        CS.Log.warn(header);

        CS.Log.warn('Populating quote object...');

        var  quoteDataOnline = {};
        // HEADER - remaining fields are here, no need for redundancy

        function toFullMonthDateNew(d){
            var monthNames = [ "January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December" ];   
            return monthNames[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
        }

        CS.Log.warn('Quote_Creation_Date_0: ' + CS.getAttributeValue('Quote_Creation_Date_0'));
        header.QuoteDate = toFullMonthDateNew(new Date(CS.getAttributeValue('Quote_Creation_Date_0')));
        CS.Log.warn('QuoteDate: ' + header.QuoteDate);
        
        header.TotalPricePayable = formatPrice(CS.getAttributeValue('Total_Price_Payable_0'));
        header.Deposit = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
        header.DepositReference = '' + CS.getAttributeValue('Deposit_Receipt_Number_0');
        header.DepositPaidBy = CS.getAttributeValue('Payment_Type_0');
        
        var balance = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0); 
        header.Balance = formatPrice(balance);
        
        header.BalancePaidBy = CS.getAttributeValue('Payment_Option_0');

         quoteDataOnline.Header = header;

        // customer needs
        var customerNeeds = "During the visit today, you expressed the following needs and requirements:";
         quoteDataOnline.CustomerNeeds = customerNeeds;

        // ************** DETAILS ****************
        var details = {};
        details.Description = CS.getAttributeValue('Reason_for_Quotation_0');
        
        function addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList){
            var section = getSectionById(sectionId, sectionList); //find if section exists, otherwise create a new section
            if (section === null) {
                section = new Section(sectionId, sectionName);
                sectionList.push(section);
            }
            section.Text = (section.Text === '' ? description : (section.Text + '\n' + description)) ;
            section.addToSubtotal(aggregatedPriceInclVAT);
        }
        
        function addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId){
            var sectionLevel1 = getParentSection(sectionId, allSectionList); // get level 1 section id from all sections list
        
            var section = getSectionById(sectionLevel1.Id, sectionList); // check if a section with that id exists in sectionList, otherwise create a new section
            if (section === null) {
                section = new Section(sectionLevel1.Id, sectionLevel1.Name);
                sectionList.push(section);                     
            }
            
            product = getSectionById(sectionId, section.Products); // find a lvl2 section (product) if exists within that section, otherwise create new lvl 2 section
            if (product === null) {
                product = new Product(sectionId, sectionName);
                section.addProduct(product);
            }
        
            // add the item as line item
            var lineItem = new LineItem(description, quantity, aggregatedPriceInclVAT, aggregatedPriceInclVAT, lineItemId);
            product.addLineItem(lineItem);
        }
            
        //new QUote development
        //quoteNewDevelopment
        function extractAssociatedParts(parent){
             var aPList =[];
             for (var key in partsModelJS) {
                if(key == parent){
                    if (partsModelJS.hasOwnProperty(key)) {        
                        //if part
                        if(partsModelJS[key].isPart){
                            if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                                CS.Log.warn('PART==');
                                CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                    
                                
                                if(partsModelJS[key]['associatedParts'].length>0){
                                    console.log("Associated Parts");
                                    for(var aPart in partsModelJS[key]['associatedParts']){
                                        if(partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c']){
                    
                                            var parentSectionLevel= partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                                            var parentSectionName=partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                    
                                            var sectionId = partsModelJS[key]['associatedParts'][aPart]['part']['CS_Template_Section_Header__c'];
                    
                                            console.log('Part =='+partsModelJS[key]['associatedParts'][aPart]['part']['Description__c']+'  SKill=='+partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c']+'  Price=='+partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT']+' quantity=='+partsModelJS[key]['associatedParts'][aPart]['quantity']);
                                            var aPLI = new AssociatedPartLineItem(sectionId, 
                                                    partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c'], 
                                                    partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c'],
                                                    partsModelJS[key]['associatedParts'][aPart]['part']['Description__c'],
                                                    partsModelJS[key]['associatedParts'][aPart]['part']['Quote_Description__c'],
                                                    partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT'], 
                                                    partsModelJS[key]['associatedParts'][aPart]['quantity'], 
                                                    parentSectionName, 
                                                    parentSectionLevel,
                                                    partsModelJS[key]['associatedParts'][aPart]['part']['Id']);
                    
                                            aPList.push(aPLI);
                                        }
                                    }
                                }
                                else{
                                    CS.Log.warn('No associated parts');
                                }
                                CS.Log.warn('----------');
                            }
                            
                    
                        }
                    
                        //if bundle
                        else{
                            if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                                CS.Log.warn('BUNDLE==');
                                CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                                CS.Log.warn('----------');
                            }
                        }
                    }
                } 
            }
            return aPList;
         }
        


        function iterateQuoteParts(){
            var partsList = [];
        
            for (var key in partsModelJS) {
                if (partsModelJS.hasOwnProperty(key)) {        
                //if part
                if(partsModelJS[key].isPart){
                    if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                        CS.Log.warn('PART==');
                        CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
            
                        var sectionId = partsModelJS[key]['parentPart']['part']['CS_Template_Section_Header__c'];
                        var isPart = partsModelJS[key].isPart;
                        var level = partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                        var sectionName = partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                        var partDescription = partsModelJS[key]['parentPart']['part']['Quote_Description__c'];
                        var price = partsModelJS[key]['parentPart']['priceVatIncl'];
                        var quantity = partsModelJS[key]['parentPart']['quantity'];
                        var associatedParts = extractAssociatedParts(key);
                        var lineItemId = partsModelJS[key]['parentPart']['part']['Id'];
                        var partItem = new PartQuoteItem(isPart, sectionId, level, sectionName, partDescription, price, quantity, associatedParts, lineItemId);
                                            
        
                        console.log(partItem);
        
                        partsList.push(partItem);
                    }   
            
                }
            
                //if bundle
                else{
                    if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                        CS.Log.warn('BUNDLE==');
                        CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                        CS.Log.warn('----------');
                    }
                }
              }
            } 
        
            return partsList;
        }


        function addAssociatedPartsNewQuote(sectionList, allSectionList){
            var pL = iterateQuoteParts();
                for(p in pL){
                    if(pL[p] && pL[p].associatedPartsList && pL[p].associatedPartsList.length>0){
                        for(ap in pL[p].associatedPartsList){
                            console.log("In my Test=="+pL[p].associatedPartsList[ap].level);
                            if(pL[p].associatedPartsList[ap].level == SectionLevel1){
                                console.log('+++++++++Adding level 1');
                                addLevel1SectionNew(pL[p].associatedPartsList[ap].sectionId, pL[p].associatedPartsList[ap].sectionName, pL[p].associatedPartsList[ap].partDescription, pL[p].associatedPartsList[ap].price, sectionList);
                            }
                            if(pL[p].associatedPartsList[ap].level == SectionLevel2){
                                console.log('++++++++Adding level 2');
                                addLevel2SectionNew(pL[p].associatedPartsList[ap].sectionId, 
                                        pL[p].associatedPartsList[ap].sectionName, 
                                        pL[p].associatedPartsList[ap].partDescription, 
                                        pL[p].associatedPartsList[ap].price, 
                                        pL[p].associatedPartsList[ap].quantity, 
                                        sectionList, 
                                        allSectionList,
                                        pL[p].associatedPartsList[ap].lineItemId);
                            }
                        }
                    }
                }
        }
        //---end quote New development
        //--end new quote development
            
            
        function isRadiatorAttributeNew(item) {
            var attRef = item.attRef;
            // this checks only the start of the string
            if(attRef.lastIndexOf(radiator, 0) === 0) {
                if((attRef.indexOf(placeholder)>0) || (attRef.indexOf(actual)>0) || (attRef.indexOf(fittingBundle)>0)) {
                    return true;    
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
            
        function addRadiatorOrFittingBundleNew(item, radiatorMap, fittingBundleMap) {
            // get reference for map
            var attRef = item.attRef,
                len = item.attRef.indexOf(":"),
                index = attRef.substr(0, len);
            
            // add placeholders and actuals to radiator map
            // add fitting bundles to fitting bundle map
            if((attRef.indexOf(placeholder) > 0) || (attRef.indexOf(actual) > 0)) {
                radiatorMap[index] = item;
            } else if(attRef.indexOf(fittingBundle) > 0) {
                fittingBundleMap[index] = item;
            }
        }
        
        function addRadiatorsToSectionListNew(radiatorMap, fittingBundleMap, sectionList, allSectionList) {
            // iterate radiator map
            for (var attRef in radiatorMap) {
                if (!radiatorMap.hasOwnProperty(attRef)) continue;
                var rad = radiatorMap[attRef],
                    fittingBundle = fittingBundleMap[attRef];
        
                // construct radiator and add to section list
                if(!_.isEmpty(rad)) {
                    var sectionId = rad.parentPart.part.CS_Template_Section_Header__c,
                        sectionName = rad.parentPart.part.Section_Name__c ? rad.parentPart.part.Section_Name__c : '',
                        sectionLevel = rad.parentPart.part.Section_Level__c,
                        description = rad.parentPart.part.Quote_Description__c ? rad.parentPart.part.Quote_Description__c : (rad.parentPart.part.Description__c ? rad.parentPart.part.Description__c : (rad.parentPart.part.Name ? rad.parentPart.part.Name : '')),
                        aggregatedPriceInclVAT = (rad.aggregatedPriceInclVAT || rad.aggregatedPriceInclVAT === 0) ? rad.aggregatedPriceInclVAT : 0;

                    if(!_.isEmpty(fittingBundle)) {
                        CS.Log.warn('fitting bundle is not empty');
                        CS.Log.warn(fittingBundle);
                        // construct a description with fitting bundle
                        var fittingBundleName = fittingBundleNameMap[fittingBundle.parentBundle.Fitting_Pack__c];
                        description += ' (' + fittingBundleName + ')';
                        // add the fitting price to the radiator price
                        fittingBundlePrice = (fittingBundle.aggregatedPriceInclVAT || fittingBundle.aggregatedPriceInclVAT === 0) ? fittingBundle.aggregatedPriceInclVAT : 0;
                        aggregatedPriceInclVAT += fittingBundlePrice;
                    }

                    // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                    CS.Log.warn('Adding a radiator...');
                    if (sectionLevel === SectionLevel1) { 
                        addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                    } else if (sectionLevel === SectionLevel2) {
                        addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, 0);
                    }
                }
            }
        }
        
        var SectionLevel1 = 'Level 1',
            SectionLevel2 = 'Level 2';
            
        var radiator = 'Radiator_',
            actual = 'Actual_Radiator_',
            placeholder = 'Placeholder_',
            fittingBundle = 'Fitting_Bundle_';
        var radiatorMap = {},
            fittingBundleMap = {};
            fittingBundleNameMap = {
                'New location in same room': 'new fix',
                'Same place, different size': 'replacement',
                'Same place, same size': 'replacement',
                'New installation': 'new installation'
            };

        var sectionList = [];
        
        
        //iterate through build parts model and create a product structure
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id)) continue;
            var item = partsModelJS[id];

            if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {

                var quantity = 1;
                var description = '';
                var aggregatedPriceInclVAT = (item.aggregatedPriceInclVAT || item.aggregatedPriceInclVAT === 0) ? item.aggregatedPriceInclVAT : 0;
                var parentPartPrice = 0;

                if (item.isBundle) {
                    //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                    description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                    quantity = parseInt(item.attLastQuantity, 10) ? parseInt(item.attLastQuantity, 10) : 1;

                } else {
                    //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                    description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                    quantity = parseInt(item.parentPart.quantity, 10) ? parseInt(item.parentPart.quantity, 10) : 1;
                    parentPartPrice = (item.parentPart.priceVatIncl || item.parentPart.priceVatIncl === 0) ? item.parentPart.priceVatIncl : 0;
                }

                var section = null;
                var product = null;

                if(isRadiatorAttributeNew(item)) {
                    addRadiatorOrFittingBundleNew(item, radiatorMap, fittingBundleMap);
                } else {
                    if (item.isPart && !(item.isMultilookup)) {
                        CS.Log.warn('Adding a part...');
                        //get section id, name, level
                        var sectionId = item.parentPart.part.CS_Template_Section_Header__c;
                        var sectionName = item.parentPart.part.Section_Name__c ? item.parentPart.part.Section_Name__c : '';
                        var sectionLevel = item.parentPart.part.Section_Level__c;
                        var lineItemId = item.parentPart.part.Id;
                        
                        // Change made to check the .parentPart.part.Show_Parts__c flag, if the flag is true, show associated parts along with the parent part
                       
                        var showAssociatedParts = item.parentPart.part.Show_Parts__c;
                        if(showAssociatedParts) {
                            // add the parent part
                            if (sectionLevel === SectionLevel1) { 
                                addLevel1SectionNew(sectionId, sectionName, description, parentPartPrice, sectionList);        
                            } else if (sectionLevel === SectionLevel2) {
                                addLevel2SectionNew(sectionId, sectionName, description, parentPartPrice, quantity, sectionList, allSectionList, lineItemId);
                            }
                            
                           
                        } else {
                            // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                            if (sectionLevel === SectionLevel1) { 
                                addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                        
                            } else if (sectionLevel === SectionLevel2) {
                                addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId);
                            }
                        }
                        
                        
                        
                    } 
                    else if (item.isBundle) {
                        CS.Log.warn('Adding a bundle...');
                        // Change made to check the .parentBundle.Show_Parts__c flag, if the flag is true, show parts instead of bundle
                        var showParts = item.parentBundle.Show_Parts__c;
                        if (showParts) {
                            // flag is set to true, iterate through all associated parts of the bundle
                            for (var i = 0; i < item.associatedParts.length; i++) {
                                var associatedPart = item.associatedParts[i];
                                
                                var description = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                var quantity = associatedPart.quantity ? associatedPart.quantity : '';
                                var priceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                    
                                var sectionId = associatedPart.part.CS_Template_Section_Header__c;
                                var sectionName = associatedPart.part.Section_Name__c ? associatedPart.part.Section_Name__c : '';
                                var sectionLevel = associatedPart.part.Section_Level__c;
                                var lineItemId = associatedPart.part.Id;
                    
                                if (sectionLevel === SectionLevel1) {  
                                    addLevel1SectionNew(sectionId, sectionName, description, (priceVatIncl * quantity), sectionList); 
                                      
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionNew(sectionId, sectionName, description, (priceVatIncl * quantity), quantity, sectionList, allSectionList, lineItemId);
                                }
                            }      
                        } else {
                            var sectionId = item.parentBundle.CS_Template_Section_Header__c;
                            var sectionName = item.parentBundle.Section_Name__c ? item.parentBundle.Section_Name__c : '';
                            var sectionLevel = item.parentBundle.Section_Level__c;
                            var lineItemId = item.parentBundle.id;
                            
                            if (sectionLevel === SectionLevel1) { 
                                addLevel1SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList); 
                    
                            } else if (sectionLevel === SectionLevel2) {
                                addLevel2SectionNew(sectionId, sectionName, description, aggregatedPriceInclVAT, 1, sectionList, allSectionList, lineItemId);
                            }
                        }
                    }        
                }
            }
        }
        
        // add the constructed radiators
        addRadiatorsToSectionListNew(radiatorMap, fittingBundleMap, sectionList, allSectionList);

        mySectionList = sectionList;
        //new quote test dev
        addAssociatedPartsNewQuote(sectionList, allSectionList);
        //end new quote test
        
        
        details.Sections = sectionList;
         quoteDataOnline.Details = details;

        // FOOTER
        var footer = {
            TotalGrossPrice: formatPrice(CS.getAttributeValue('Gross_Price_incl_VAT_0')),
            NetContractPrice: formatPrice(CS.getAttributeValue('Total_Price_Payable_0'))
        };

        CS.Log.warn('Adding discounts...');
        var discountList = new Product(null, 'Discounts:');
        //iterate through applied allowances and add them as line items 
        for (var c = 1; c <= 6; c++) {
            var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                allowanceQuantity = '',
                allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                allowanceId = CS.getAttributeValue('Allowance' + c + '_0');

                if (allowanceDescription == '') {
                    allowanceDescription = allowanceName;
                }
            // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
            if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                var lineItem = new LineItem(allowanceDescription, allowanceQuantity, allowancePrice, allowancePrice, allowanceId);
                discountList.addLineItem(lineItem);
            }
        }
        footer.Discounts = discountList;

         quoteDataOnline.Footer = footer;

        applySequencesAndDisplayPricesNew(allSectionList,  quoteDataOnline);
    }

    function applySequencesAndDisplayPricesNew(resultList,  quoteDataOnline) {

        CS.Log.warn('Applying sequences...');
        CS.Log.warn('All Section list: ');
        CS.Log.warn(resultList);

        var sectionList =  quoteDataOnline.Details.Sections;
        CS.Log.warn(sectionList);
        
        // iterate through all of the sections and apply sequences
        for(var i=0; i<sectionList.length; i++){
            var section = sectionList[i];
            CS.Log.warn('Going through section: ' + section.Header + ' with id: ' + section.Id);

            var actualSection = getSectionById(section.Id, resultList);

            CS.Log.warn('Actual section: ');
            CS.Log.warn(actualSection);
            section.Sequence__c = actualSection.Sequence__c;
            
            var numOfProducts = section.Products ? section.Products.length : 0;
            CS.Log.warn('Num of section products: ' + numOfProducts);

            if (numOfProducts > 0){
                // iterate through all of the products, apply sequences
                for(var j=0; j<numOfProducts; j++){
                    var product = section.Products[j];
                    CS.Log.warn('Iterating through product:');
                    CS.Log.warn(product);

                    var actualProduct = getSectionById(product.Id, resultList);
                    CS.Log.warn('Actual product is: ');
                    CS.Log.warn(actualProduct);

                    product.Sequence__c = actualProduct.Sequence__c;

                    CS.Log.warn('Item totals flag: ' + actualProduct.Show_item_totals__c + ' and group totals flag: ' + actualProduct.Show_group_totals__c);
                    // clean line item totals and quantities if necessary for lvl 2 sections
                    if (!actualProduct.Show_item_totals__c) {
                        CS.Log.warn('Cleared line item totals and quantities.');
                        product.clearLineItemTotalsAndQuantities();
                    }
                    if (!actualProduct.Show_group_totals__c) {
                        CS.Log.warn('Cleared subtotals.');
                        product.SubTotal = '';
                        CS.Log.warn(product);
                    }
                }
                // sort lvl 2 sections if there are any
                section.Products.sort(function(a, b) {
                    return a.Sequence__c - b.Sequence__c;
                });
                
                if(section.Text === '') {
                    section.SubTotal = '';
                    CS.Log.warn(section);
                }
                
            } else {
                // show concise lvl 1 if it doesnt have lvl 2 sections
                CS.Log.warn('Section does not have lvl 2 sections.');
                section.concise();
                CS.Log.warn(section);
                if(section.Text === '') {
                    section.SubTotal = '';
                    CS.Log.warn(section);
                }
            }                
        }

        sectionList.sort(function(a, b) {
            return a.Sequence__c - b.Sequence__c;
        });
        
        // add a message for low cost quotes (e.g. for low cost pricebooks)
        var isLowCostQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_LowCost ? true : false;
        CS.Log.warn('Is the quote a low cost quote: ' + isLowCostQuote);
        if(isLowCostQuote) {
            var lowCostSection = new Section('noId', 'Quotation details', 0);
            lowCostSection.Text = 'The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.';
            lowCostSection.concise(); // remove the unnecessary section fields
            lowCostSection.SubTotal = ''; // remove the subtotal
            if(sectionList.length > 0) {
                sectionList.unshift(lowCostSection);
            } else {
                sectionList.push(lowCostSection);
            }
        }
        
         quoteDataOnline.Details.Sections = sectionList;
        console.log("This is the object  "+quoteDataOnline.Details);
        
        return  quoteDataOnline;
    }
    
    function createJsonFromObjectNew(quoteObject) {
    
            CS.Log.warn('Creating json from object...');
            
            quoteObjNewTest=quoteObject;
            var quoteJSON = JSON.stringify(quoteObject);
            quoteJSON = replaceJsonCharacters(quoteJSON);
            openNewQuoteForm();
        }
}
    //end new quote development



    //start Online quote development
    window.generateOnlineHTMLQuote = function generateOnlineHTMLQuote() {
        CS.Log.warn('***** generateQuote called...');
    
        var appointmentId = CS.getAttributeValue('Appointment_Id_0');
        function getHeaderDataOnline() {
            var deferred = Q.defer();
            CS.Log.warn('Getting header data...');

            UISupport.getHeaderData(
                appointmentId,
                function(result, event) {
                    if (event.status) {

                        var header = {};
                        header.Contact = result.Assigned_To_Name__c ? result.Assigned_To_Name__c : '';
                        header.QuoteNumber = result.CHI_Lead_No__c ? result.CHI_Lead_No__c : '';

                        var installationAddress = {};
                        installationAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Salutation ? result.Opportunity__r.Account.Primary_Contact__r.Salutation + ' ' : '';
                        installationAddress.Name += result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                        installationAddress.Street = result.Opportunity__r.Install_Address_Street__c ? result.Opportunity__r.Install_Address_Street__c : '';
                        installationAddress.PostalCode = result.Opportunity__r.Install_Postcode__c ? result.Opportunity__r.Install_Postcode__c : '';
                        installationAddress.Telephone = result.Opportunity__r.SC_Home_Phone__c ? result.Opportunity__r.SC_Home_Phone__c : '';
                        installationAddress.Mobile = result.Opportunity__r.SC_Mobile_Phone__c ? result.Opportunity__r.SC_Mobile_Phone__c : '';

                        var billingAddress = {};
                        billingAddress.Name = result.Opportunity__r.Account.Primary_Contact__r.Salutation ? result.Opportunity__r.Account.Primary_Contact__r.Salutation + ' ' : '';
                        billingAddress.Name += result.Opportunity__r.Account.Primary_Contact__r.Name ? result.Opportunity__r.Account.Primary_Contact__r.Name : '';
                        billingAddress.Street = result.Opportunity__r.Account.Primary_Contact__r.MailingStreet ? result.Opportunity__r.Account.Primary_Contact__r.MailingStreet : '';
                        billingAddress.PostalCode = result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ? result.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode : '';
                        billingAddress.Telephone = result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c ? result.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c : '';
                        billingAddress.Mobile = result.Opportunity__r.Account.Primary_Contact__r.MobilePhone ? result.Opportunity__r.Account.Primary_Contact__r.MobilePhone : '';

                        header.InstallationAddress = installationAddress;
                        header.BillingAddress = billingAddress;

                        deferred.resolve(header);
                    } else {
                        deferred.reject('Event failed');
                    }
                }
            );
            return deferred.promise;
            
        }
    
        function getSectionListOnline() {
    
           
            var deferred = Q.defer();

            UISupport.getAllSections(
                function(result, event) {
                    if (event.status) {

                        deferred.resolve(result);
                    } else {
                        deferred.reject('Event failed');
                    }
                }
            );
            return deferred.promise; 
            
        }
        
        Q.all([getHeaderDataOnline(), getSectionListOnline()]).then(function(result){
            CS.Log.warn('Q.all result:');
            CS.Log.warn(result[0]);
            CS.Log.warn(result[1]);
            var params = {
                headerData: result[0],
                allSections: result[1]    
            };

            return populateJsonObjectOnline(params);
        })
        .fail(function(e) { 
            CS.Log.error(e);
        });
        
    
        /**
         * Used to create a json string to be sent for pdf quote generation.
         * @param {Object} header   an object containing custom header data retreived from server.
         */
        function populateJsonObjectOnline(params) {

            var header = params.headerData;
            var allSectionList =  params.allSections;
            
            CS.Log.warn(header);
    
            CS.Log.warn('Populating quote object...');
    
            var quoteObject = {};
            // HEADER - remaining fields are here, no need for redundancy
    
            function toFullMonthDate(d){
                var monthNames = [ "January", "February", "March", "April", "May", "June",
                    "July", "August", "September", "October", "November", "December" ];   
                return monthNames[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
            }
    
            CS.Log.warn('Quote_Creation_Date_0: ' + CS.getAttributeValue('Quote_Creation_Date_0'));
            header.QuoteDate = toFullMonthDate(new Date(CS.getAttributeValue('Quote_Creation_Date_0')));
            CS.Log.warn('QuoteDate: ' + header.QuoteDate);
            
            header.TotalPricePayable = formatPrice(CS.getAttributeValue('Total_Price_Payable_0'));
            header.Deposit = formatPrice(CS.getAttributeValue('Actual_Deposit_0'));
            header.DepositReference = '' + CS.getAttributeValue('Deposit_Receipt_Number_0');
            header.DepositPaidBy = CS.getAttributeValue('Payment_Type_0');
            
            var balance = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0); 
            header.Balance = formatPrice(balance);
            
            header.BalancePaidBy = CS.getAttributeValue('Payment_Option_0');
    
            quoteObject.Header = header;
    
            // customer needs
            var customerNeeds = "During the visit today, you expressed the following needs and requirements:";
            quoteObject.CustomerNeeds = customerNeeds;
    
            // ************** DETAILS ****************
            var details = {};
            details.Description = CS.getAttributeValue('Reason_for_Quotation_0');
            
            function addLevel1SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList){
                var section = getSectionById(sectionId, sectionList); //find if section exists, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionId, sectionName);
                    sectionList.push(section);
                }
                section.Text = (section.Text === '' ? description : (section.Text + '\n' + description)) ;
                section.addToSubtotal(aggregatedPriceInclVAT);
            }
            
            function addLevel2SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId){
                var sectionLevel1 = getParentSection(sectionId, allSectionList); // get level 1 section id from all sections list
            
                var section = getSectionById(sectionLevel1.Id, sectionList); // check if a section with that id exists in sectionList, otherwise create a new section
                if (section === null) {
                    section = new Section(sectionLevel1.Id, sectionLevel1.Name);
                    sectionList.push(section);                     
                }
                
                product = getSectionById(sectionId, section.Products); // find a lvl2 section (product) if exists within that section, otherwise create new lvl 2 section
                if (product === null) {
                    product = new Product(sectionId, sectionName);
                    section.addProduct(product);
                }
            
                // add the item as line item
                var lineItem = new LineItem(description, quantity, aggregatedPriceInclVAT, aggregatedPriceInclVAT, lineItemId);
                product.addLineItem(lineItem);
            }
              
            //associated parts - new display
             function extractAssociatedPartsOnline(parent){
                 var aPList =[];
                 for (var key in partsModelJS) {
                    if(key == parent){
                        if (partsModelJS.hasOwnProperty(key)) {        
                            //if part
                            if(partsModelJS[key].isPart){
                                if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                                    CS.Log.warn('PART==');
                                    CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                        
                                    
                                    if(partsModelJS[key]['associatedParts'].length>0){
                                        console.log("Associated Parts");
                                        for(var aPart in partsModelJS[key]['associatedParts']){
                                            if(partsModelJS[key]['associatedParts'][aPart]['part'] != undefined && partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c']){
                        
                                                var parentSectionLevel= partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                                                var parentSectionName=partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                        
                                                var sectionId = partsModelJS[key]['associatedParts'][aPart]['part']['CS_Template_Section_Header__c'];
                        
                                                console.log('Part =='+partsModelJS[key]['associatedParts'][aPart]['part']['Description__c']+'  SKill=='+partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c']+'  Price=='+partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT']+' quantity=='+partsModelJS[key]['associatedParts'][aPart]['quantity']);
                                                var aPLI = new AssociatedPartLineItem(sectionId, 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Level__c'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Section_Name__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Description__c'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Quote_Description__c'],
                                                        partsModelJS[key]['associatedParts'][aPart]['totalPriceIncVAT'], 
                                                        partsModelJS[key]['associatedParts'][aPart]['quantity'], 
                                                        parentSectionName, 
                                                        parentSectionLevel,
                                                        partsModelJS[key]['associatedParts'][aPart]['part']['Id']);
                        
                                                aPList.push(aPLI);
                                            }
                                        }
                                    }
                                    else{
                                        CS.Log.warn('No associated parts');
                                    }
                                    CS.Log.warn('----------');
                                }
                                
                        
                            }
                        
                            //if bundle
                            else{
                                if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                                    CS.Log.warn('BUNDLE==');
                                    CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                                    CS.Log.warn('----------');
                                }
                            }
                        }
                    } 
                }
                return aPList;
             }
            
            function iterateOldQuotePartsOnline(){
                var partsList = [];
            
                for (var key in partsModelJS) {
                    if (partsModelJS.hasOwnProperty(key)) {        
                    //if part
                    if(partsModelJS[key].isPart){
                        if(partsModelJS[key]['parentPart']['part']['Section_Name__c']){
                        
                            CS.Log.warn(partsModelJS[key]['parentPart']['part']['Section_Name__c'] +' - '+partsModelJS[key]['parentPart']['part']['Section_Level__c']);
                
                            var sectionId = partsModelJS[key]['parentPart']['part']['CS_Template_Section_Header__c'];
                            var isPart = partsModelJS[key].isPart;
                            var level = partsModelJS[key]['parentPart']['part']['Section_Level__c'];
                            var sectionName = partsModelJS[key]['parentPart']['part']['Section_Name__c'];
                            var partDescription = partsModelJS[key]['parentPart']['part']['Quote_Description__c'];
                            var price = partsModelJS[key]['parentPart']['priceVatIncl'];
                            var quantity = partsModelJS[key]['parentPart']['quantity'];
                            var associatedParts = extractAssociatedPartsOnline(key);
                            var lineItemId = partsModelJS[key]['parentPart']['part']['Id'];
                            var partItem = new PartQuoteItem(isPart, sectionId, level, sectionName, partDescription, price, quantity, associatedParts, lineItemId);
                                                
            
                           
            
                            partsList.push(partItem);
                        }   
                
                    }
                
                    //if bundle
                    else{
                        if(partsModelJS[key]['parentBundle']['Section_Name__c']){
                            CS.Log.warn('BUNDLE==');
                            CS.Log.warn(partsModelJS[key]['parentBundle']['Section_Name__c'] +' - '+partsModelJS[key]['parentBundle']['Section_Level__c']);
                            CS.Log.warn('----------');
                        }
                    }
                  }
                } 
            
                return partsList;
            }


            function addAssociatedPartsOldQuoteOnline(sectionList, allSectionList){
                var pL = iterateOldQuotePartsOnline();
                    for(p in pL){
                        if(pL[p] && pL[p].associatedPartsList && pL[p].associatedPartsList.length>0){
                            for(ap in pL[p].associatedPartsList){
                                
                                if(pL[p].associatedPartsList[ap].level == SectionLevel1){
                                    
                                    addLevel1SectionOnline(pL[p].associatedPartsList[ap].sectionId, pL[p].associatedPartsList[ap].sectionName, pL[p].associatedPartsList[ap].partDescription.replace(/\\r\\n/g, ""), pL[p].associatedPartsList[ap].price, sectionList);
                                    
                                    
                                }
                                if(pL[p].associatedPartsList[ap].level == SectionLevel2){
                                    
                                    addLevel2SectionOnline(pL[p].associatedPartsList[ap].sectionId, 
                                            pL[p].associatedPartsList[ap].sectionName, 
                                            pL[p].associatedPartsList[ap].partDescription.replace(/\\r\\n/g, ""), 
                                            pL[p].associatedPartsList[ap].price, 
                                            pL[p].associatedPartsList[ap].quantity, 
                                            sectionList, 
                                            allSectionList,
                                            pL[p].associatedPartsList[ap].lineItemId);
                                }
                            }
                        }
                    }
            }
            
            //end
            
            function isRadiatorAttributeOnline(item) {
                var attRef = item.attRef;
                // this checks only the start of the string
                if(attRef.lastIndexOf(radiator, 0) === 0) {
                    if((attRef.indexOf(placeholder)>0) || (attRef.indexOf(actual)>0) || (attRef.indexOf(fittingBundle)>0)) {
                        return true;    
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
                
            function addRadiatorOrFittingBundleOnline(item, radiatorMap, fittingBundleMap) {
                // get reference for map
                var attRef = item.attRef,
                    len = item.attRef.indexOf(":"),
                    index = attRef.substr(0, len);
                
                // add placeholders and actuals to radiator map
                // add fitting bundles to fitting bundle map
                if((attRef.indexOf(placeholder) > 0) || (attRef.indexOf(actual) > 0)) {
                    radiatorMap[index] = item;
                } else if(attRef.indexOf(fittingBundle) > 0) {
                    fittingBundleMap[index] = item;
                }
            }
            
            function addRadiatorsToSectionListOnline(radiatorMap, fittingBundleMap, sectionList, allSectionList) {
                // iterate radiator map
                for (var attRef in radiatorMap) {
                    if (!radiatorMap.hasOwnProperty(attRef)) continue;
                    var rad = radiatorMap[attRef],
                        fittingBundle = fittingBundleMap[attRef];
            
                    // construct radiator and add to section list
                    if(!_.isEmpty(rad)) {
                        var sectionId = rad.parentPart.part.CS_Template_Section_Header__c,
                            sectionName = rad.parentPart.part.Section_Name__c ? rad.parentPart.part.Section_Name__c : '',
                            sectionLevel = rad.parentPart.part.Section_Level__c,
                            lineItemId = rad.parentPart.part.Id;
                            description = rad.parentPart.part.Quote_Description__c ? rad.parentPart.part.Quote_Description__c : (rad.parentPart.part.Description__c ? rad.parentPart.part.Description__c : (rad.parentPart.part.Name ? rad.parentPart.part.Name : '')),
                            aggregatedPriceInclVAT = (rad.aggregatedPriceInclVAT || rad.aggregatedPriceInclVAT === 0) ? rad.aggregatedPriceInclVAT : 0;

                             //quantity issue fix
                            var quantity = 1;
                            //if part
                            if(rad.isPart){
                                quantity = rad.parentPart.quantity;
                                CS.Log.warn("NEW QUANTITY FOR PART =="+quantity);
                            }
                        
                            CS.Log.warn('Added quantity fix');

                        if(!_.isEmpty(fittingBundle)) {
                            CS.Log.warn('fitting bundle is not empty');
                            CS.Log.warn(fittingBundle);
                            // construct a description with fitting bundle
                            var fittingBundleName = fittingBundleNameMap[fittingBundle.parentBundle.Fitting_Pack__c];
                            description += ' (' + fittingBundleName + ')';
                            // add the fitting price to the radiator price
                            fittingBundlePrice = (fittingBundle.aggregatedPriceInclVAT || fittingBundle.aggregatedPriceInclVAT === 0) ? fittingBundle.aggregatedPriceInclVAT : 0;
                            aggregatedPriceInclVAT += fittingBundlePrice;
                            //quantity fix
                            if(fittingBundle.isBundle){
                                quantity = fittingBundle.attLastQuantity;
                                CS.Log.warn("NEW QUANTITY FOR BUNDLE =="+quantity);
                            }
                        }

                        // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                        CS.Log.warn('Adding a radiator...');
                        if (sectionLevel === SectionLevel1) { 
                            addLevel1SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                        } else if (sectionLevel === SectionLevel2) {
                            addLevel2SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId);
                        }
                    }
                }
            }
            
            var SectionLevel1 = 'Level 1',
                SectionLevel2 = 'Level 2';
                
            var radiator = 'Radiator_',
                actual = 'Actual_Radiator_',
                placeholder = 'Placeholder_',
                fittingBundle = 'Fitting_Bundle_';
            var radiatorMap = {},
                fittingBundleMap = {};
                fittingBundleNameMap = {
                    'New location in same room': 'new fix',
                    'Same place, different size': 'replacement',
                    'Same place, same size': 'replacement',
                    'New installation': 'new installation'
                };
    
            var sectionList = [];
            //iterate through build parts model and create a product structure
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id)) continue;
                var item = partsModelJS[id];
    
                if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
    
                    var quantity = 1;
                    var description = '';
                    var aggregatedPriceInclVAT = (item.aggregatedPriceInclVAT || item.aggregatedPriceInclVAT === 0) ? item.aggregatedPriceInclVAT : 0;
                    var parentPartPrice = 0;
    
                    if (item.isBundle) {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                        quantity = parseInt(item.attLastQuantity, 10) ? parseInt(item.attLastQuantity, 10) : 1;
    
                    } else {
                        //take Quote_Description__c, if Quote_Description__c is empty take Description__c, if Description__c is empty take Name
                        description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                        quantity = parseInt(item.parentPart.quantity, 10) ? parseInt(item.parentPart.quantity, 10) : 1;
                        parentPartPrice = (item.parentPart.priceVatIncl || item.parentPart.priceVatIncl === 0) ? item.parentPart.priceVatIncl : 0;
                    }
    
                    var section = null;
                    var product = null;
    
                    if(isRadiatorAttributeOnline(item)) {
                        addRadiatorOrFittingBundleOnline(item, radiatorMap, fittingBundleMap);
                    } else {
                        if (item.isPart && !(item.isMultilookup)) {
                            CS.Log.warn('Adding a part...');
                            //get section id, name, level
                            var sectionId = item.parentPart.part.CS_Template_Section_Header__c;
                            var sectionName = item.parentPart.part.Section_Name__c ? item.parentPart.part.Section_Name__c : '';
                            var sectionLevel = item.parentPart.part.Section_Level__c;
                            var lineItemId = item.parentPart.part.Id;
                            
                            // Change made to check the .parentPart.part.Show_Parts__c flag, if the flag is true, show associated parts along with the parent part
                            var showAssociatedParts = item.parentPart.part.Show_Parts__c;
                            if(showAssociatedParts) {
                                // add the parent part
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionOnline(sectionId, sectionName, description, parentPartPrice, sectionList);        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionOnline(sectionId, sectionName, description, parentPartPrice, quantity, sectionList, allSectionList, lineItemId);
                                }
                                // add the associated parts
                                CS.Log.warn('Adding associated parts...');
                                /* --- associated parts
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    var aPdescription = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var aPquantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var aPpriceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                                    
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1Section(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), sectionList); 
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2Section(sectionId, sectionName, aPdescription, (aPpriceVatIncl * aPquantity), aPquantity, sectionList, allSectionList);
                                    }
                                }
                                */
                            } else {
                                // all Level 1 sections will be shown with descriptions concatenated, prices aggregated to one sum
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList);        
                            
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, quantity, sectionList, allSectionList, lineItemId);
                                }
                            }
                        } 
                        else if (item.isBundle) {
                            CS.Log.warn('Adding a bundle...');
                            // Change made to check the .parentBundle.Show_Parts__c flag, if the flag is true, show parts instead of bundle
                            var showParts = item.parentBundle.Show_Parts__c;
                            if (showParts) {
                                // flag is set to true, iterate through all associated parts of the bundle
                                for (var i = 0; i < item.associatedParts.length; i++) {
                                    var associatedPart = item.associatedParts[i];
                                    
                                    var description = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                                    var quantity = associatedPart.quantity ? associatedPart.quantity : '';
                                    var priceVatIncl = (associatedPart.priceVatIncl || associatedPart.priceVatIncl === 0) ? associatedPart.priceVatIncl : '';
                        
                                    var sectionId = associatedPart.part.CS_Template_Section_Header__c;
                                    var sectionName = associatedPart.part.Section_Name__c ? associatedPart.part.Section_Name__c : '';
                                    var sectionLevel = associatedPart.part.Section_Level__c;
                                    var lineItemId = associatedPart.part.Id;
                        
                                    if (sectionLevel === SectionLevel1) {  
                                        addLevel1SectionOnline(sectionId, sectionName, description, (priceVatIncl * quantity), sectionList); 
                                          
                                    } else if (sectionLevel === SectionLevel2) {
                                        addLevel2SectionOnline(sectionId, sectionName, description, (priceVatIncl * quantity), quantity, sectionList, allSectionList, lineItemId);
                                    }
                                }      
                            } else {
                                var sectionId = item.parentBundle.CS_Template_Section_Header__c;
                                var sectionName = item.parentBundle.Section_Name__c ? item.parentBundle.Section_Name__c : '';
                                var sectionLevel = item.parentBundle.Section_Level__c;
                                var lineItemId = item.parentBundle.Id;
                                
                                if (sectionLevel === SectionLevel1) { 
                                    addLevel1SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, sectionList); 
                        
                                } else if (sectionLevel === SectionLevel2) {
                                    addLevel2SectionOnline(sectionId, sectionName, description, aggregatedPriceInclVAT, 1, sectionList, allSectionList, lineItemId);
                                }
                            }
                        }        
                    }
                }
            }
            
            // add the constructed radiators
            addRadiatorsToSectionListOnline(radiatorMap, fittingBundleMap, sectionList, allSectionList);
    
            //associated parts
            addAssociatedPartsOldQuoteOnline(sectionList, allSectionList);
            //end
    
            details.Sections = sectionList;
            quoteObject.Details = details;
    
            // FOOTER
            var footer = {
                TotalGrossPrice: formatPrice(CS.getAttributeValue('Gross_Price_incl_VAT_0')),
                NetContractPrice: formatPrice(CS.getAttributeValue('Total_Price_Payable_0'))
            };
    
            CS.Log.warn('Adding discounts...');
            var discountList = new Product(null, 'Discounts:');
            //iterate through applied allowances and add them as line items 
            for (var c = 1; c <= 6; c++) {
                var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                    allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                    allowanceQuantity = '',
                    allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                    allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                    allowanceId = CS.getAttributeValue('Allowance' + c + '_0');

                    if (allowanceDescription == '') {
                        allowanceDescription = allowanceName;
                    }
                // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
                if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                    var lineItem = new LineItem(allowanceDescription, allowanceQuantity, allowancePrice, allowancePrice, allowanceId);
                    discountList.addLineItem(lineItem);
                }
            }
            footer.Discounts = discountList;
    
            quoteObject.Footer = footer;
    
            applySequencesAndDisplayPricesOnline(allSectionList, quoteObject);
        }
        
    
        function applySequencesAndDisplayPricesOnline(resultList, quoteObject) {
    
            CS.Log.warn('Applying sequences...');
            CS.Log.warn('All Section list: ');
            CS.Log.warn(resultList);
    
            var sectionList = quoteObject.Details.Sections;
            CS.Log.warn(sectionList);
            
            // iterate through all of the sections and apply sequences
            for(var i=0; i<sectionList.length; i++){
                var section = sectionList[i];
                CS.Log.warn('Going through section: ' + section.Header + ' with id: ' + section.Id);
    
                var actualSection = getSectionById(section.Id, resultList);
    
                CS.Log.warn('Actual section: ');
                CS.Log.warn(actualSection);
                section.Sequence__c = actualSection.Sequence__c;
                
                var numOfProducts = section.Products ? section.Products.length : 0;
                CS.Log.warn('Num of section products: ' + numOfProducts);
    
                if (numOfProducts > 0){
                    // iterate through all of the products, apply sequences
                    for(var j=0; j<numOfProducts; j++){
                        var product = section.Products[j];
                        CS.Log.warn('Iterating through product:');
                        CS.Log.warn(product);
    
                        var actualProduct = getSectionById(product.Id, resultList);
                        CS.Log.warn('Actual product is: ');
                        CS.Log.warn(actualProduct);
    
                        product.Sequence__c = actualProduct.Sequence__c;
    
                        CS.Log.warn('Item totals flag: ' + actualProduct.Show_item_totals__c + ' and group totals flag: ' + actualProduct.Show_group_totals__c);
                        // clean line item totals and quantities if necessary for lvl 2 sections
                        if (!actualProduct.Show_item_totals__c) {
                            CS.Log.warn('Cleared line item totals and quantities.');
                            product.clearLineItemTotalsAndQuantities();
                        }
                        if (!actualProduct.Show_group_totals__c) {
                            CS.Log.warn('Cleared subtotals.');
                            product.SubTotal = '';
                            CS.Log.warn(product);
                        }
                    }
                    // sort lvl 2 sections if there are any
                    section.Products.sort(function(a, b) {
                        return a.Sequence__c - b.Sequence__c;
                    });
                    
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                    
                } else {
                    // show concise lvl 1 if it doesnt have lvl 2 sections
                    CS.Log.warn('Section does not have lvl 2 sections.');
                    section.concise();
                    CS.Log.warn(section);
                    if(section.Text === '') {
                        section.SubTotal = '';
                        CS.Log.warn(section);
                    }
                }                
            }
    
            sectionList.sort(function(a, b) {
                return a.Sequence__c - b.Sequence__c;
            });
            
            // add a message for low cost quotes (e.g. for low cost pricebooks)
            var isLowCostQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_LowCost ? true : false;
            CS.Log.warn('Is the quote a low cost quote: ' + isLowCostQuote);
            if(isLowCostQuote) {
                var lowCostSection = new Section('noId', 'Quotation details', 0);
                lowCostSection.Text = 'The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.';
                lowCostSection.concise(); // remove the unnecessary section fields
                lowCostSection.SubTotal = ''; // remove the subtotal
                if(sectionList.length > 0) {
                    sectionList.unshift(lowCostSection);
                } else {
                    sectionList.push(lowCostSection);
                }
            }
            
            quoteObject.Details.Sections = sectionList;
            // TODO: 
            var financeTemplateTable = populateFinanceTableInput();
            quoteObject = _.extend(quoteObject, financeTemplateTable);
            //
            createJsonFromObjectOnline(quoteObject);
        }
    
        function createJsonFromObjectOnline(quoteObject) {
    
            CS.Log.warn('Creating json from object...');
            
            var quoteJSON = JSON.stringify(quoteObject);
            quoteJSON = replaceJsonCharacters(quoteJSON);
            CS.Log.warn(quoteJSON);

            quoteObjNewTest=quoteObject;
            openNewQuoteFormOnline('BG');
        }

    } 
    //end online quote development
    
});


//online quote

window.openNewQuoteFormOnline = function openNewQuoteFormOnline(logoType) {
        function monthlyPayment(amount,term) {
            var numOfMonths = parseInt(12, 10);
            var annualInterestRate = 0.149;
            var monthlyInterestRate = parseFloat((Math.pow((1 + annualInterestRate), (1/12)) - 1).toFixed(7));
            
            // IFC Special case (no interest)
            var value1 = amount;
            var value3 = 24;
            
            if (term > 2) {
                var value2 = Math.pow((1 + monthlyInterestRate), -1 * numOfMonths * term);
                value1 = parseFloat(amount * monthlyInterestRate);
                value3 = parseFloat(1 - value2);
            } 
    
            var monthlyPayment = parseFloat(value1 / value3).toFixed(2);
         
            CS.Log.info("monthlyPayment: " + monthlyPayment);
        
            monthlyPayment = monthlyPayment.replace(/./g, function(c, i, a) {
                return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
            });
    
            return monthlyPayment;
        }
    
        function totalAmountRepayable(amount,term) {
    
            var numOfMonths = parseInt(12, 10);
            var annualInterestRate = 0.149;
            var monthlyInterestRate = parseFloat((Math.pow((1 + annualInterestRate), (1/12)) - 1).toFixed(7));
            
            // IFC Special case (no interest)
            var value1 = amount;
            var value3 = 24;
            
            if (term > 2) {
                var value2 = Math.pow((1 + monthlyInterestRate), -1 * numOfMonths * term);
                value1 = parseFloat(amount * monthlyInterestRate);
                value3 = parseFloat(1 - value2);
            } 
            var monthlyPayment = parseFloat(value1 / value3).toFixed(2);
    
            var financeTerm = parseInt(term, 10);
    
            //var totalAmountPayable = parseFloat(monthlyPayment * numOfMonths * financeTerm).toFixed(2);
    
            var totalAmountPayable = parseFloat(monthlyPayment * numOfMonths * financeTerm).toFixed(0);
            CS.Log.info("totalAmountPayable: " + totalAmountPayable);
    
            totalAmountPayable = totalAmountPayable.replace(/./g, function(c, i, a) {
                return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
            });
    
            return totalAmountPayable;
        }

        var templateName = "NewQuote";   
        var isSmallCommercialQuote = CS.getAttributeValue('Pricebook_Type_0') == CS_PricebookType_SmallCommercial ? true : false;
        CS.Log.warn('Is the quote a Small Commercial quote: ' + isSmallCommercialQuote);
        if(isSmallCommercialQuote) {
            templateName = "SmallCommercialQuote";
        }

         var associatedPartsList =[];
         var company="British Gas";
         var transactionId = ""+CS.Service.config["CHI_Lead_Number_0"].attr.cscfga__Display_Value__c;
         var quoteNumber = ""+quoteObjNewTest.Header.QuoteNumber;
         var quoteDate = quoteObjNewTest.Header.QuoteDate;
         var depositReceiptNumber = quoteObjNewTest.Header.DepositReference;
         var allowancesApplied =  allowancesApplied();
         var billingPostcode = CS.Service.config["Billing_Postcode_0"].attr.cscfga__Display_Value__c;
         var billingCounty =CS.Service.config["Billing_County_0"].attr.cscfga__Display_Value__c;
         var billingStreet =CS.Service.config["Billing_Street_0"].attr.cscfga__Display_Value__c;
         var installationAddress = "";
         var customerName = quoteObjNewTest.Header.InstallationAddress.Name;
         var hsaName = quoteHsaName;
         var hsaContactNumber = quoteHsaNum ||"";
         var ballonTotalPrice = formatPriceComma(CS.getAttributeValue('Total_Price_Payable_0'));
         var ballonDiscount = quoteObjNewTest.Footer.Discounts.SubTotal;
         var depositPaidBy = CS.Service.config["Payment_Type_0"].attr.cscfga__Display_Value__c;
         var deposit = formatPriceComma(CS.getAttributeValue('Actual_Deposit_0'));
         var balanceOutstanding=formatPriceComma(CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c);
         
         //if(navigator.){
             balanceOutstanding='&pound;'+CS.Service.config["Balance_Outstanding_0"].attr.cscfga__Display_Value__c;
         //}
         var totalNetPrice = formatPriceComma(CS.Service.config["Total_Net_Price_0"].attr.cscfga__Display_Value__c);
         
         if(CS.isCsaContext){
            totalNetPrice='&pound;'+CS.Service.config["Total_Net_Price_0"].attr.cscfga__Display_Value__c;
         }
         
         var balanceToBePaidBy = CS.Service.config["Payment_Option_0"].attr.cscfga__Display_Value__c;
         //var amount = parseFloat(CS.getAttributeValue('Total_Price_Payable_0')); // {Total Price - Total Allowances}
         
          //2016 - value based on deposit
        var amount = (parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) ? parseFloat(CS.getAttributeValue('Total_Price_Payable_0')) : 0) - (parseFloat(CS.getAttributeValue('Actual_Deposit_0')) ? parseFloat(CS.getAttributeValue('Actual_Deposit_0')) : 0);

        if(CS.isCsaContext){
            amount = (CS.getAttributeValue('Total_Price_Payable_0') ? CS.getAttributeValue('Total_Price_Payable_0') : 0) - (CS.getAttributeValue('Actual_Deposit_0') ? CS.getAttributeValue('Actual_Deposit_0') : 0);

        }
         
         var amountFormatted;
         if(CS.isCsaContext){
             amountFormatted = '&pound;'+ amount.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
         }
         else{
             amountFormatted = amount.toFixed(2).replace(/./g, function(c, i, a) {
                    return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
             });
         }

        /*
        ballonTotalPrice = parseFloat(CS.getAttributeValue('Total_Price_Payable_0'));
        ballonTotalPrice = ballonTotalPrice.toFixed(2).replace(/./g, function(c, i, a) {
                return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
         });
         
         ballonTotalPrice = '&pound;'+ballonTotalPrice;
         */
         
         var mmp_2 = '&pound;' +monthlyPayment(amount,2);
         var mmp_3 = '&pound;'+monthlyPayment(amount,3);
         var mmp_5 = '&pound;'+monthlyPayment(amount,5);
         var mmp_8 = '&pound;'+monthlyPayment(amount,8);
         var mmp_10 = '&pound;'+monthlyPayment(amount,10);
         var tar_2 = '&pound;' + totalAmountRepayable(amount,2);
         var tar_3 = '&pound;'+totalAmountRepayable(amount,3);
         var tar_5 = '&pound;'+totalAmountRepayable(amount,5);
         var tar_8 = '&pound;'+totalAmountRepayable(amount,8);
         var tar_10 = '&pound;'+totalAmountRepayable(amount,10);
            
            
            
        function allowancesApplied(){
            CS.Log.warn('NEW++++++++ALLOWANCES++++++');
            //returns string of allowances actually applied to the quote
            var applied={};
             //iterate through applied allowances and add them as line items 
            for (var c = 1; c <= 6; c++) {
                var allowanceName = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceName'),
                    allowanceDescription = CS.getAttributeFieldValue('Allowance' + c + '_0', 'AllowanceDescription'),
                    allowancePrice = CS.getAttributeFieldValue('Allowance' + c + '_0', 'ActualAmount'),
                    allowanceIs_Applied = CS.getAttributeFieldValue('Allowance' + c + '_0', 'Is_Applied'),
                    allowanceId = CS.getAttributeValue('Allowance' + c + '_0');
    
                    if (allowanceDescription == '') {
                        allowanceDescription = allowanceName;
                    }
                // When clicking on button 7, all allowances are set as Applied. However not all 6 fields necessarily hold an allowance value
                if (allowanceIs_Applied === 'TRUE' && allowanceId && allowanceId !== '') {
                    applied[allowanceDescription]=allowancePrice;
                }
            }
            if(jQuery.isEmptyObject(applied)){
                return "No allowances applied";
            }else{
                var total=0;
                var str="<table style='width:100%;' id='allowances-table'>";
                jQuery.each(applied, function(key, value) {
                    str+="<tr><td>"+key+"</td><td style='font-weight: normal;'>"+formatPriceComma(value)+"</td></tr>";
                    total+=value;
                });
                //add a footer row
                str+="<tr class='boldText'><td>Total Allowances</td><td>"+formatPriceComma(CS.Service.config["Total_Allowance_Value_0"].attr.cscfga__Value__c)+"</td></tr>";
                str+="</table>";
    
                return str;
            }
        }
    
        var logoPng = "<img class='bgLogo' src='BG_logo_s.png' />";
         var yourQuote = 'Your British Gas Quotation';

                CS.Log.warn("Now available online");
                //new online quote
                 //TRADING NAME - SCOTTISH GAS -- Boundary Changes
                //getDynamicLookupValue('AppointmentQuery','Trading_Name__c').then(function(tradeName) {
                      var tradeName = 'British Gas';
                        if(tradeName == 'Scottish Gas'){
                            logoPng = "<img class='bgLogo' src='SG_logo_s.png' />";
                            yourQuote = "Your Scottish Gas Quotation";
                            company="Scottish Gas";
                        }
                        
                    CS.Log.warn('MY POSTCODE == '+tradeName);                        //new line 

                      /**
                         * An entity representing a quote summary line shown 
                         * on the first page of online PDF quote
                         */
                         var SectionPrice = function(trClass, name, nameClass, amount, amountClass) {
                            this.trClass = trClass;
                            this.name = name;
                            this.nameClass = nameClass;
                            this.amount = amount;
                            this.amountClass = amountClass;
                         };
                    var sectionPricesObj = [];

                  
                    var firstLoop = false;
                    
                    //Section price summary
                    for(sec in quoteObjNewTest.Details.Sections) {
                         var totalPrice=0;
                            if (quoteObjNewTest.Details.Sections[sec].Products) {
                                for(pr in quoteObjNewTest.Details.Sections[sec].Products){
                                    for(lin in quoteObjNewTest.Details.Sections[sec].Products[pr].LineItems){
                                        if(quoteObjNewTest.Details.Sections[sec].Products[pr].LineItems[lin].Price){
                                            totalPrice+=parseFloat(quoteObjNewTest.Details.Sections[sec].Products[pr].LineItems[lin].Price.split(';')[1]);
                                        }
                                        
                                    }
                                    
                                }
                                
                            } else {
                                if(quoteObjNewTest.Details.Sections[sec].SubTotal){
                                    totalPrice = quoteObjNewTest.Details.Sections[sec].SubTotal.split(';')[1];
                                }

                    
                            }
                        
                        if(quoteObjNewTest.Details.Sections[sec].Header){
                            
                            if(firstLoop == false){
                                firstLoop = true;
                                //IC added additional class and name attribute
                                sectionPricesObj.push(new SectionPrice('topBorder', 
                                                                quoteObjNewTest.Details.Sections[sec].Header, 
                                                                'summary-section', 
                                                                formatPriceComma(totalPrice), 
                                                                'section-price right'));
                            } else {
                                sectionPricesObj.push( new SectionPrice('', 
                                                                        quoteObjNewTest.Details.Sections[sec].Header, 
                                                                        'summary-section', 
                                                                        formatPriceComma(totalPrice), 
                                                                        'section-price right'));
                            }
                        }
                        
                    }      
                    function allowancesExists(){
                         var allowanceExists = false;
                         for(var ind =1; ind<7; ind++){
                            var allRef = "Allowance"+ind+"_0";
                            if((CS.Service.config[allRef].attributeFields["Is_Applied"].cscfga__Value__c == 'TRUE') && (CS.getAttributeValue(allRef)) &&(CS.getAttributeValue(allRef)!="")){
                                allowanceExists = true;
                            }
                         }
                         
                         return allowanceExists;
                    }
                    
                    
                    // add Total Gross price
                    sectionPricesObj.push(
                         new SectionPrice('', 
                                 'Total gross price (inc. VAT)', 
                                 'summary-section', 
                                 formatPriceComma(CS.Service.config["Gross_Price_incl_VAT_0"].attr.cscfga__Value__c), 
                                 'section-price right')); 
                    
                    // if allowances exist, append title for allowances
                    if (allowancesExists()) {
                        sectionPricesObj.push( 
                            new SectionPrice('', 
                                             'Our offers for you', 
                                             'boldText slate', 
                                             '', 
                                             'section-price right'));
                    }
                                        
                                        
                    //allowances applied
                    function addAllowancesToSection(){

                        var allowanceLines = [];

                        for (var ind = 1; ind < 7; ind++) {
                            var allRef = "Allowance"+ind+"_0";
                    
                            if((CS.Service.config[allRef].attributeFields["Is_Applied"].cscfga__Value__c == 'TRUE') && (CS.getAttributeValue(allRef)) &&(CS.getAttributeValue(allRef)!="")){
                                var allName = CS.Service.config[allRef].attributeFields["AllowanceName"].cscfga__Value__c;
                                if(CS.Service.config[allRef].attributeFields["AllowanceDescription"].cscfga__Value__c !=""){
                                    allName = CS.Service.config[allRef].attributeFields["AllowanceDescription"].cscfga__Value__c;
                                }
                                var allAmount = formatPriceComma(CS.Service.config[allRef].attributeFields["ActualAmount"].cscfga__Value__c);

                                allowanceLines.push(new SectionPrice('', allName, 'allowance-label', allAmount, 'allowance-value right'));
                            }
                        }
                        
                        return allowanceLines;
                    }
                    
                    
                    

                    var allowanceLines = addAllowancesToSection();
                    var allowanceExists = allowancesExists();
                    
                    if (allowanceExists==true ){
                        sectionPricesObj = sectionPricesObj.concat(allowanceLines);
                    }

                    //total discount
                    if(allowanceExists==true){
                        allowanceLines.push(
                            new SectionPrice('', 
                                            'Total discount', 
                                            'discount-total boldText', 
                                            formatPriceComma(CS.Service.config["Total_Allowance_Value_0"].attr.cscfga__Value__c), 
                                            'section-total boldText right'));
                    }
                   

                    //Breakdown table (this will go to visualforce controller)
                    // instead of raw html, we'll create an array of objects which contain necessary data
                    // we'll do all the work in the vf controller
                    var quoteBreakDownTable = quoteObjNewTest.Details;

                    //Installation address
                    installationAddress="<p>"+quoteObjNewTest.Header.InstallationAddress.Street+"</p>";
                    installationAddress += "<p>"+quoteObjNewTest.Header.InstallationAddress.PostalCode+"</p>";
                    
                    var dearCustomer = "<h3>Dear "+customerName+"</h3>";
                    
                    
                    function getPaymentDetails(totalPricePayable, deposit, depositReceiptNumber,depositPaidBy, balance, balanceToBePaidBy){
                     
                        var htmlResult = ""
                        
                        htmlResult+="<h4>Payment</h4>";
                        //IC updated set to sentence case
                        htmlResult+="<p>Total price payable: <span id='totalNetPrice'>"+totalPricePayable+"</span></p>"; 
                        
                        htmlResult+="<p>Deposit:<span id='deposit'>"+deposit+"</span></p>";
                        htmlResult+="<p>Deposit number:<span id='depositReceiptNumber'>"+depositReceiptNumber+"</span></p>"; 
                        htmlResult+="<p>Deposit paid by:<span id='depositPaidBy'>"+depositPaidBy+"</span></p>"; 
                        htmlResult+="<p>Balance:<span id='balanceOutstanding'>"+balance+"</span></p>"; 
                        htmlResult+="<p>Balance to be paid by: <span id='balanceToBePaidBy'>"+balanceToBePaidBy+"</span></p>"; 
                        
                        return htmlResult;
                    }
                    
                
                    function getFooterContacts(hsaName, hsaContactNumber, quoteReference){
                    //IC updated removed colon
                    var str="<p style='font-size:85%'>"
                    +"To accept this quote, the simplest way is to go online via our portal&#42;, "
                    +"to discuss it further or make any changes please contact <span id='hsaName'>"+hsaName+"</span> on <span id='hsaContactNumber'>"+hsaContactNumber+"</span>"
                    +" or alternatively call us on 0333 202 9488. (Option 3)</p>";
                    return str;
                    }
                   var paymentDetails = getPaymentDetails(ballonTotalPrice,deposit,depositReceiptNumber,depositPaidBy,balanceOutstanding, balanceToBePaidBy);
                   
                   var footerContactsDetails = getFooterContacts(hsaName, hsaContactNumber, quoteNumber);
                   
                   var partsModelJS_stringified = JSON.stringify(partsModelJS);
                   var jobTitle = CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") ? "Job Title: "+CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0") : '';
                   
                   var jsonObject = { 
                       "logoPng":logoPng,
                        "logoPng2":logoPng,
                        "logoPng3":logoPng,
                        "transactionId":transactionId,
                        "quoteNumber":CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"],
                        "quoteDate":quoteDate,
                        "depositReceiptNumber":depositReceiptNumber,
                        "allowancesApplied":allowancesApplied,
                        "billingPostcode":billingPostcode,
                        "billingCounty":billingCounty,
                        "billingStreet":billingStreet,
                        "installationAddress":installationAddress,
                        "customerName":customerName,
                        "hsaName":hsaName,
                        "hsaContactNumber":hsaContactNumber,
                        "sectionPrices":sectionPricesObj,
                        "ballonTotalPrice":ballonTotalPrice,
                        "breakdownQuoteTable":quoteBreakDownTable,
                        "deposit":deposit,
                        "totalNetPrice":ballonTotalPrice,
                        "balanceToBePaidBy":balanceToBePaidBy,
                        "balanceOutstanding":balanceOutstanding,
                        "depositPaidBy":depositPaidBy,
                        "quoteRef":quoteNumber,
                        "quoteRef2":quoteNumber,
                        "mmp_2":mmp_2,
                        "mmp_3":mmp_3,
                        "mmp_5":mmp_5,
                        "mmp_8":mmp_8,
                        "mmp_10":mmp_10,
                        "tar_2":tar_2,
                        "tar_3":tar_3,
                        "tar_5":tar_5,
                        "tar_8":tar_8,
                        "tar_10":tar_10,
                        "waysToPayTotalAmount":ballonTotalPrice,
                        "waysToPayDeposit":deposit,
                        "waysToPayBalance":balanceOutstanding,
                        "minMonthlyTotal":mmp_10,
                        "illustrationDeposit":deposit,
                        "illustrationTotal":ballonTotalPrice,
                        "illustrationLoanAmount":balanceOutstanding,
                        "illustrationBalance":balanceOutstanding,
                        "paymentDetails":paymentDetails,
                        "footerContactsDetails":footerContactsDetails,
                        "company1":company,
                        "company2":company,
                        "tradeName":tradeName,
                        "partsModel":partsModelJS_stringified,
                        "chi_lead_created_date": CS.Service.config.CHI_Lead_Created_Date_0.attr.CreatedDate,
                        "jobTitle":jobTitle
                        
                    }
                    
                    var jsonString = JSON.stringify(jsonObject);

                    //jsonString = btoa(jsonString);
                    jsonString = btoa(unescape(encodeURIComponent(jsonString)));
        
                     var content = jsonString;

                    UISupport.AttachTempFileReturnId(
                                    CS.getAttributeValue("Appointment_Id_0"),
                                    "TEMP_Online_Quote"+ '.txt',
                                    content,
                                    function(result, event) {
                                        if(event.status) {
                                            CS.Log.warn(result);
                                            window.open('/apex/CSQuoteOnline?attId=' 
                                                     + result
                                                     + '&appId='    + CS.getAttributeValue("Appointment_Id_0")
                                                     + '&oppId='    + CS.getAttributeValue('CHI_Lead_Id_0')
                                                     + '&quoteRef=' + CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"]
                                                     + '&logoType=' + logoType);
                                        }
                                    }
                                );
                    
            
    
        };

//end online quote

window.installationTemplateOnlineGenerate = function installationTemplateOnlineGenerate(logoType){

    var content = generateInstallationNotesData(logoType);

    UISupport.AttachTempFileReturnId(
                    CS.getAttributeValue("Appointment_Id_0"),
                    "TEMP_INSTALLATION_NOTE"+ '.txt',
                    content,
                    function(result, event) {
                        if(event.status) {
                            CS.Log.warn(result);
                             window.open('/apex/CSInstallationNotes?attId=' + result+'&appId='+CS.getAttributeValue("Appointment_Id_0")+'&oppId='+CS.getAttributeValue('CHI_Lead_Id_0')+'&quoteRef='+CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"]+'&logoType='+logoType);
                        }
                    }
                );
}


window.quoteTemplateOnlineGenerate = function quoteTemplateOnlineGenerate(logoType){

    var content = generateQuoteOnlineData(logoType);

    UISupport.AttachTempFileReturnId(
                    CS.getAttributeValue("Appointment_Id_0"),
                    "TEMP_QUOTE_ONLINE"+ '.txt',
                    content,
                    function(result, event) {
                        if(event.status) {
                            CS.Log.warn(result);
                             window.open('/apex/CSQuoteOnline?attId=' + result+'&appId='+CS.getAttributeValue("Appointment_Id_0")+'&oppId='+CS.getAttributeValue('CHI_Lead_Id_0')+'&quoteRef='+CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"]+'&logoType='+logoType);
                        }
                    }
                );
}

window.quoteTemplateOnlineSave = function quoteTemplateOnlineSave(logoType){

    var content = generateInstallationNotesData(logoType);

    UISupport.AttachTempFileReturnId(
                    CS.getAttributeValue("Appointment_Id_0"),
                    "TEMP_QUOTE_ONLINE"+ '.txt',
                    content,
                    function(result, event) {
                        if(event.status) {
                            
                             UISupport.SaveInstallationNotesPdf(result, CS.getAttributeValue("Appointment_Id_0"), CS.getAttributeValue('CHI_Lead_Id_0'), CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"], logoType,
                                function(result, event){
                                    if(event.status) {
                                        CS.Log.warn('Saving pdf');
                                    }
                                }
                            );
                        }
                    }
                );
}

window.generateQuoteOnlineData = function generateQuoteOnlineData(logoType){
     
     var htmlContent = "<div style='border:2px black solid;border-radius:2px;'>THIS IS A TEST</div>";

     var jsonObject = {
               "content":htmlContent,
               "LogoPng":logoType

            };

            var jsonString = JSON.stringify(jsonObject);

            //jsonString = btoa(jsonString);
            jsonString = btoa(unescape(encodeURIComponent(jsonString)));

            return jsonString;
}

window.installationTemplateOnlineSave = function installationTemplateOnlineSave(logoType, quoteAccepted, basketId, configId){

    var content = generateInstallationNotesData(logoType);

    UISupport.AttachTempFileReturnId(
                    CS.getAttributeValue("Appointment_Id_0"),
                    "TEMP_INSTALLATION_NOTE"+ '.txt',
                    content,
                    function(result, event) {
                        if(event.status) {
                            
                             UISupport.SaveInstallationNotesPdf(result, CS.getAttributeValue("Appointment_Id_0"), CS.getAttributeValue('CHI_Lead_Id_0'), CS.Service.config["Quote_Reference_0"].attr["cscfga__Display_Value__c"], logoType, quoteAccepted, basketId, configId,
                                function(result, event){
                                    if(event.status) {
                                        CS.Log.warn('Saving pdf');
                                    }
                                }
                            );
                        }
                    }
                );
}


//new installation updated IC Dec 2017
window.generateInstallationNotesData = function generateInstallationNotesData(logoType){

    var asbestosIdentified= CS.getAttributeValue('Asbestos_Identified_0', 'String');//Yes~No

    var suspectMaterials=false;
    //check if new definition has been deployed
    try{
       var obj = CS.Service.config['Suspected_Materials_0'];
       if(obj){suspectMaterials=true;}
    }
    catch(err){
    }

    var  logoPng = "<img class='bgLogo' src='BG_logo_s.png'></img>";
    var footerText="is the trading name of British Gas New Heating Limited.  Registered in England & Wales (No. 06723244). Registered office: Millstream, Maidenhead Road, Windsor, Berkshire SL4 5GD.";

    var asbestosConfirmed = "";
    
    if(logoType == 'SG'){
        footerText="Scottish Gas "+footerText+" britishgas.co.uk";
         if(CS.getAttributeValue('Asbestos_Identified_0') == 'No'){
            asbestosConfirmed = 'I confirm that I am unaware of the presence or possible presence of any asbestos materials in my property. Should asbestos materials be found in my property during the boiler installation, that Scottish Gas could not reasonably identify when providing this quote, I am aware that I will be responsible for the cost of removing all asbestos and obtaining a "site clearance for reoccupation" certificate before Scottish Gas can continue to work at my property.'
        }
    }
    else{
        footerText="British Gas "+footerText+" britishgas.co.uk";
        
        if(CS.getAttributeValue('Asbestos_Identified_0') == 'No'){
        asbestosConfirmed = 'I confirm that I am unaware of the presence or possible presence of any asbestos materials in my property. Should asbestos materials be found in my property during the boiler installation, that British Gas could not reasonably identify when providing this quote, I am aware that I will be responsible for the cost of removing all asbestos and obtaining a "site clearance for reoccupation" certificate before British Gas can continue to work at my property.'
        }
    }
            
            
            var constructedAddress = '',
                newline = '\n',
                delimiter = ', ';

            var boilerNotes;
            var flueNotes;
            var gasWaterNotes;
            var disruptionNotes;
            var disruptionNotes;

            try{
                var bExists = CS.Service.config['Installer_Notes_Boiler_0'];
                if(bExists){
                    boilerNotes = CS.getAttributeValue('Installer_Notes_Boiler_0','String');
                    boilerNotes = addLineBreak(boilerNotes);
                }
                else{
                    boilerNotes="";
                }
            }
            catch(err){
                boilerNotes="";
            }

            try{
                var flueExists = CS.Service.config['Installer_Notes_Flue_0'];
                if(flueExists){
                    flueNotes = CS.getAttributeValue('Installer_Notes_Flue_0','String');
                    flueNotes = addLineBreak(flueNotes);
                }
                else{
                    flueNotes="";
                }  
            }
            catch(err){
                flueNotes="";
            }

            try{
                 var gasExists = CS.Service.config['Installer_Notes_GasWater_0'];
                if(gasExists){
                   gasWaterNotes = CS.getAttributeValue('Installer_Notes_GasWater_0','String');
                   gasWaterNotes = addLineBreak(gasWaterNotes);
                }
                else{
                    gasWaterNotes="";
                }
            }
            catch(err){
                gasWaterNotes="";
            }

            try{
                disruptionNotes = CS.getAttributeValue('Installer_Notes_Disruption_0','String');
                disruptionNotes = addLineBreak(disruptionNotes);
            }
            catch(err){
                disruptionNotes="";
            }
            
            try{
                specialCustomerNotes = CS.getAttributeValue('Installer_Notes_Special_Customer_Requirements_0','String');
                specialCustomerNotes = addLineBreak(specialCustomerNotes);
            }
            catch(err){
                specialCustomerNotes="";
            }
            
            
            

            var AllNotesString = boilerNotes + newline + newline + flueNotes + newline + newline + gasWaterNotes + newline + newline + disruptionNotes + newline + newline + specialCustomerNotes;
            
            var boilerHeading ="";
            if(boilerNotes!=""){
                boilerHeading ="<div style='padding:2px;font-size:16px;color:#091E73;'>Installer Notes - Boiler</div>";
            }

            var flueHeading ="";
            if(flueNotes!=""){
                flueHeading ="<div style='padding:2px;font-size:16px;color:#091E73;'>Installer Notes - Flue</div>";
            }

            var gasWaterHeading ="";
            if(gasWaterNotes!=""){
                gasWaterHeading ="<div style='padding:2px;font-size:16px;color:#091E73;'>Installer Notes - Gas/Water</div>";
            }

            var disruptionHeading ="";
            if(disruptionNotes!=""){
                disruptionHeading ="<div style='padding:2px;font-size:16px;color:#091E73;'>Installer Notes - Disruption</div>";
            }

            var specialCustomerHeading ="";
            if(specialCustomerNotes!=""){
                specialCustomerHeading ="<div style='padding:2px;font-size:16px;color:#091E73;'>Installer Notes - Special customer requirements (including details of any planned home improvement work)</div>";
            }


            AllNotesString=boilerHeading+"<p style='padding:2px;font-size:14px;'>"+boilerNotes+"</p>"+ flueHeading+"<p style='padding:2px;font-size:14px;'>"+flueNotes+"</p>"+gasWaterHeading+"<p style='padding:2px;font-size:14px;'>"+gasWaterNotes+"</p>"+disruptionHeading+"<p style='padding:2px;font-size:14px;'>"+disruptionNotes+"</p>"+ specialCustomerHeading +"<p style='padding:2px;font-size:14px;'>"+specialCustomerNotes+"</p>";

            if((boilerNotes=="")&&(flueNotes=="")&&(gasWaterNotes=="")&&(disruptionNotes=="")&&(specialCustomerNotes=="")){
                AllNotesString="--None--";
            }

            var chiLeadNumberString = "";

            try{
                chiLeadNumberString = CS.Service.config["CHI_Lead_Number_0"].attr["cscfga__Display_Value__c"];
            }
            catch(err){
                chiLeadNumberString ="Unable to display CHI Lead Number";
            }

            var showRads=actualRadiatorExistis();//true~false
            var radiatorTableHtml='';
            if(showRads==true){radiatorTableHtml=createRadiatorTable();}
            
            var asbestosIdentified= CS.getAttributeValue('Asbestos_Identified_0', 'String');
            
            var asbestosNotes = '';
            if(CS.Service.config["Asbestos_Location_0:Asbestos_Location_0"]){
                asbestosNotes=CS.getAttributeValue('Asbestos_Location_0:Asbestos_Location_0', 'String');
            }
            
            var asbestosIdentifiedStr='';
            var asbestosNotesStr='';
            

            if(suspectMaterials==false && asbestosIdentified=="Yes"){
                //--This is the old asbestos process--// 
                    var str = "<table class='shadedTable' id='asbestosLocationsTable'>";
                    var i=0;
                     while(CS.Service.config['Asbestos_Location_'+i]){ 
                        var asbestosLocationString = "";
                        try {
                            asbestosLocationString = CS.Service.config["Asbestos_Location_"+i+":Asbestos_Location_0"].attr["cscfga__Display_Value__c"];
                        }
                        catch(err) {
                            asbestosLocationString = "--None--";
                        }
                    
                        str+="<tr><td><td>"+i+"</td><td>"+asbestosLocationString+"</td></tr>";
                        if(CS.Service.config['Asbestos_Location_'+i]){i++} else break;

                    } 
                    str+="</table>";
                    asbestosNotesStr=str;
            }
            
            /*
            if(asbestosIdentified != 'Yes'){
                 asbestosIdentifiedStr="<span class='noAsbestos'>No asbestos has been identified</span>";
            }
            */

             var suspectMaterialsTable='';
            //build the NEW suspect materials table
            if(suspectMaterials==true && asbestosIdentified=='Yes'){                
                var l = CS.getAttributeWrapper('Suspected_Materials_0').relatedProducts.length; 
                var str = "<table class='shadedTable'>";
                str+="<tr>"
                str+="<th>ID</th><th>Room</th><th>Type</th><th>Disturbed</th><th>Is sample required</th><th>Removal action</th>";
                str+="</tr>";
                for (var i=0, l; i < l; i++) {
                    //add a new row'
                    var def='Suspected_Materials_'+i;
                    console.log(def);
                    var css='';
                    if(CS.getAttributeValue(def+":SampleReq_0","String")=='PP26'){css="class='red'";}
                    var row="<tr "+css+">"
                    row+="<td>"+i+"</td>"
                    +"<td>"+CS.getAttributeValue(def+":Room_0","String")+"</td>"
                    +"<td>"+CS.getAttributeValue(def+":Type_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":Disturbed_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":SampleReq_0","String")+"</td>"
                    +"<td>"+CS.getAttributeDisplayValue(def+":Action_type_0","String")+"</td>"
                    +"</tr>";
                    str+=row;
                }
                str+="</table>";
                suspectMaterialsTable=str;
            }
            
            /*
            if(asbestosNotes && asbestosNotes !=''){
                asbestosNotesStr =addAsbestosLocation();
            }
            */
            
            
            //line breaks
            var ladderWork = '';
            if(CS.Service.config['Scaffold_Notes_0']){
                ladderWork = CS.getAttributeValue('Scaffold_Notes_0', 'String');
                ladderWork = addLineBreak(ladderWork);
                
            }
            else{
                ladderWork='--None--';
                
            }
            
            
            var systemChar = '';
            if(CS.Service.config['System_Characteristics_Notes_0']){
                 systemChar = CS.getAttributeValue('System_Characteristics_Notes_0', 'String');
                    systemChar = addLineBreak(systemChar);
                
            }
            else{
                systemChar='--None--';
                
            }
           
            
            var removalAssistance = '';
            if(CS.Service.config['Component_Removal_Notes_0']){
                removalAssistance = CS.getAttributeValue('Component_Removal_Notes_0', 'String');
                removalAssistance = addLineBreak(removalAssistance);
                
            }
            else{
                removalAssistance='--None--';
                
            }
            
            
            var workAreaRestriction = '';
            if(CS.Service.config['Work_Area_Restrictions_Notes_0']){
                workAreaRestriction = CS.getAttributeValue('Work_Area_Restrictions_Notes_0', 'String');
                workAreaRestriction = addLineBreak(workAreaRestriction);
                
            }
            else{
                workAreaRestriction='--None--';
                
            }
            
            
            var workAreaHazard = '';
            if(CS.Service.config['Work_Area_Hazards_Notes_0']){
                workAreaHazard = CS.getAttributeValue('Work_Area_Hazards_Notes_0', 'String');
                workAreaHazard = addLineBreak(workAreaHazard);
                
            }
            else{
                workAreaHazard='--None--';
                
            }
            
            var boilerDetailsTable ='';
            if(CS.Service.config['Boiler_0:Boiler_0']){
                if(CS.Service.config["Boiler_0"].relatedProducts.length>0){
                    boilerDetailsTable = getBoilerDetailsTable();
                }
            }

            var custEmail=CS.getAttributeValue('Boiler_0:Controls_0:Customer_Email_Address_2_0');
            //--check if a boiler IQ OR HIVE component requiring email has been added--//
            var connectedProductAdded='FALSE';

            if(partsModelJS){
                for(var id in partsModelJS){
                    //console.log(id);
                    try{
                        var code=partsModelJS[id].parentPart.part.Part_Code__c;
                    }
                    catch(err){
                        var code='';
                    }
                    console.log(code)
                     if(code=='PSLT1' || code=='PSLT2' || code=='PSLT3' || code=="PSLT4" || code=='PCBH1' || code=='PCBH2'){
                        connectedProductAdded='TRUE';
                        break;
                    }
                }
            }

        function today(){
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();

                if(dd<10) {dd='0'+dd} 
                if(mm<10) {mm='0'+mm} 
                return dd+'/'+mm+'/'+yyyy;
          }
             var definitionName = CS.getAttributeValue("Definition_Name_0") ? CS.getAttributeValue("Definition_Name_0") : '';

            // 2019-09-03 customerAddress changed to CS.getAttributeValue('Installation_Address_0') instead of CS.getAttributeValue('Customer_Address_0')
            var instAddr = CS.getAttributeValue('Installation_Address_0');
            /*if (!instAddr && CS.isCsaContext) {
                var appointmentId = CS.getAttributeValue('Appointment_Id_0');

                CS.DB.smartQuery("SELECT {Appointment__c:_soup} FROM {Appointment__c} WHERE {Appointment__c:Id} = '" + appointmentId + "'").then(function(qr) {
                    return qr.getAll().then(function (results) {
                           
                        if (results.length > 0) {
                            var appointment = results[0][0];
                            return CS.DB.smartQuery("SELECT {Opportunity:_soup} FROM {Opportunity} WHERE {Opportunity:Id} = '" + appointment.Opportunity__c + "'").then(function(qr) {
                                return qr.getAll().then(function (r) {
                                    
                                    if (r && r.length > 0) {
                                        instAddr = r[0][0].Install_Address_Street__c 
                                            + ', ' + r[0][0].Install_Address_City__c 
                                            + ', ' + r[0][0].Install_Address_County__c
                                            + ', ' + r[0][0].Install_Postcode__c
                                            + ', ' + r[0][0].Country__c;
                                        CS.Log.warn('***** Installation Address: ' + instAddr);
                                    }
                                });
                            });
                        }
                    });
                })
                .fail(function(error) {
                    CS.Log.error(error);
                });
            }*/


            var jsonObject = {
                "AccessNotes" :  workAreaRestriction,
                "AllNotes" : AllNotesString,
                "asbestosConfirmed" : asbestosConfirmed,
               // "AsbestosIdentified" : asbestosIdentifiedStr, IC removed 10/01/2018
                "asbestosIdentified":asbestosIdentified,
                "AsbestosNotes" : asbestosNotesStr,
                "boilerDetailsTable": boilerDetailsTable,
                "CHILeadNumber": chiLeadNumberString,
                "connectedEmail":custEmail,
                "connectedProductAdded":connectedProductAdded,
                "customerAddress":instAddr,
                "CustomerArrange" : CS.getAttributeValue('Customer_to_Arrange_0', 'String') || '--None--',
                "productDefinition":definitionName,
                "EarthLocation" : CS.getAttributeValue('Earthing_Location_0', 'String') || '--None--',
                "EarthSystem" : CS.getAttributeValue('Earth_System_Type_0', 'String') || '--None--',
                "Flow" : CS.getAttributeValue('Boiler_0:Flow_Rate_0', 'String') || '--None--',
                "FooterText" : footerText,
                "LadderWork" :  ladderWork,
                "LogoPng" : logoPng,
                "Peb" : CS.getAttributeValue('Protective_Earth_Bonding_Required_0', 'String') || '--None--',
                "quoteReference":CS.getAttributeValue('Quote_Reference_0'),
                "Radiator" : radiatorTableHtml || '',
                "Rdc" : CS.getAttributeValue('RCD_0', 'String') || '--None--',
                "RemovalAssistance" :  removalAssistance,
                "Scaffolding" : CS.getAttributeValue('Scaffolding_Required_0', 'String') || '--None--',
                "Seb" : CS.getAttributeValue('Supplementary_Bonding_Required_0', 'String') || '--None--',
                "SocketSee" : CS.getAttributeValue('Socket_and_See_reading_0', 'String') || '--None--',
                "suspectMaterials":suspectMaterialsTable,
                "SystemCharacter" :  systemChar,
                "VisibleEarth" : CS.getAttributeValue('Visible_Earth_0', 'String') || '--None--',
                "Voelcb" : CS.getAttributeValue('Working_VOELCB_0', 'String') || '--None--',
                "visitDate":today(),
                "WaterTestPressure" : CS.getAttributeValue('Boiler_0:Standing_Pressure_0', 'String') || '--None--',
                "WorkAreas" : workAreaHazard,
                "jobTitle":CS.getAttributeValue("Customer_Identity_Check_0:Job_Role_0", "String"),
                "definitionName":CS.getAttributeValue("Definition_Name_0", "String")

            };

            var jsonString = JSON.stringify(jsonObject);

            //jsonString = btoa(jsonString);
            jsonString = btoa(unescape(encodeURIComponent(jsonString)));

            return jsonString;

}


window.getBoilerDetailsTable = function getBoilerDetailsTable(){
    var boilerHTML = '<h3>Boiler Details</h3>';
    
    var boilerTable ="<table class='shadedTable'>";
    boilerTable +="<tr>";
    boilerTable +="<th>Boiler</th>";
    boilerTable +="<th>Type</th>";
    boilerTable +="<th>Location</th>";
    boilerTable +="<th>Available space</th></tr>";
    
    var boilerDescriptionWithCode='';
    var boilerLocation ='';
    var boilerDimensions='';
    if(CS.Service.config["Boiler_0:Boiler_0"] && CS.Service.config["Boiler_0:Installation_Location_0"] && CS.Service.config["Boiler_0:Depth_0"] && CS.Service.config["Boiler_0:Width_0"]&& CS.Service.config["Boiler_0:Height_0"]){
        boilerDescriptionWithCode = CS.Service.config["Boiler_0:Boiler_0"].attr.cscfga__Display_Value__c || '';
        boilerType=CS.Service.config['Boiler_0:Boiler_System_0'].attr.cscfga__Display_Value__c || '';
        boilerLocation = CS.Service.config["Boiler_0:Installation_Location_0"].attr.cscfga__Display_Value__c || '';
        boilerDimensions =CS.Service.config["Boiler_0:Height_0"].attr.cscfga__Display_Value__c+'H x '+CS.Service.config["Boiler_0:Depth_0"].attr.cscfga__Display_Value__c+'D x '+CS.Service.config["Boiler_0:Width_0"].attr.cscfga__Display_Value__c+'W';
        
    }
    
    boilerTable +="<tr>";
        boilerTable+="<td>"+boilerDescriptionWithCode+"</td>";
        boilerTable+="<td>"+boilerType+"</td>";
        boilerTable+="<td>"+boilerLocation+"</td>";
        boilerTable+="<td>"+boilerDimensions+"</td>";
    boilerTable+="</tr>";

    if(boilerType=="Combination"){
        var flow=CS.Service.config['Boiler_0:Flow_Rate_0'].attr.cscfga__Display_Value__c || '';
        var bar=CS.Service.config['Boiler_0:Standing_Pressure_0'].attr.cscfga__Display_Value__c || '';

        boilerTable +="<tr>";
            boilerTable+="<td colspan='4' style='background-color:white'>Water Performance Tests: Flow rate: "+flow+" (l/min), Water test pressure: "+bar+" (bar)</td>";
        boilerTable+="</tr>";
    }

    boilerTable+="</table>";
    
    boilerHTML +=boilerTable;
    return boilerHTML;
}

window.createRadiatorTable = function createRadiatorTable(){

    var showPrice=false;
    //--has FR allowance been applied?--//
    for (var i = 1; i < 7; i++) {
        var allRef = "Allowance"+i+"_0";
        var applied = CS.Service.config[allRef].attributeFields["Is_Applied"].cscfga__Value__c;
        var code= CS.Service.config[allRef].attributeFields["Code"].cscfga__Value__c;

        if((applied == 'TRUE' && code=="FR")){
            showPrice=true;
            break;
        }
    }

        var str ="<h3>Radiator Details</h3>"
        str +="<table class='shadedTable'>";
        str +="<tr>";
        str +="<th>Rad</th>";
        str +="<th>Radiator</th>";
        if(showPrice){
            str +="<th>Price&#42;</th>";
        }
        str +="<th>Fitting Pack</th>";
        str +="<th>Room Name</th>";
        str +="<th>Room Location</th></tr>";
        
        var hlTable ='';
        
        if(radiatorExistis()){
            str += addRadiatorsFromRelObject('Radiator');
            hlTable +=addHLFromRelObject('Radiator');
        }
        if(actualRadiatorExistis()){
            str += addRadiatorsFromRelObject('Actual_Radiator', showPrice);
            hlTable +=addHLFromRelObject('Actual_Radiator');
        }
        
        str+="</table>";

        if(showPrice){
            str+="<p style='font-size:smaller'>&#42;This is the radiator only price, excludes radiator valves and installation.</p>";
        }

        if(hlTable!=''){
            str+="<p>Heatloss was not calculated for following radiators:</p><table class='shadedTable'><tr><th class='bold'>Rad</th><th class='bold'>Reason</th></tr>";
            str+=hlTable;
            str+="</table>";

        }
        return str;
    };
    
window.addRadiatorsFromRelObject = function addRadiatorsFromRelObject(relObjectName, showPrice){
    var i=0;
    
    var rowsInHtmlTable = "";
    relObjectName = relObjectName+'_';

    var radIndex =1;
    while(CS.Service.config[relObjectName+i]){ 
        var radiatorString = relObjectName+i;
        var radiatorString = "";
        try {
            radiatorString = CS.Service.config[relObjectName+i+":Radiator_Description_0"].attr["cscfga__Display_Value__c"];
        }
        catch(err) {
            radiatorString = "";
        }
        var roomNameString = CS.getAttributeValue(relObjectName +i+":Room_Type_0") || '';
        var locationString = CS.getAttributeValue(relObjectName +i+":Location_Within_Room_0") || '';
        var fittingPackString = CS.getAttributeValue(relObjectName +i+":Fitting_Pack_0") || '';
        var manufacturer = CS.getAttributeValue(relObjectName +i+":Manufacturer_0") || '';
        console.log('get radiator price from partsModelJS');
        var radiatorPriceString='';
        if(manufacturer !="MHS"){
            radiatorPriceString='&pound;'+partsModelJS[relObjectName+i+':Radiator_0'].aggregatedPriceInclVAT;
        }
        
        var hlc = '';
        if(relObjectName=='Radiator'){
            var hlcVal = CS.getAttributeValue(relObjectName +i+":Heatloss_Required_0") || '';
            if(hlcVal && hlcVal=='Yes'){
                hlc = 'Y';
            }
            else{
                hlc = 'N';
            }
        }
        else{
            var hlcVal = CS.getAttributeValue(relObjectName +i+":Override_Reason_0") || '';
            if(hlcVal && hlcVal!=''){
                hlc = 'Y';
            }
            else{
                hlc = 'N';
            }
        }
        rowsInHtmlTable+=addRadiatorRow(radIndex, radiatorString, fittingPackString, roomNameString, locationString, radiatorPriceString,showPrice);
        if(CS.Service.config[relObjectName +i]){i++;radIndex++;} else break;
    } 
    
    return rowsInHtmlTable;
}

window.addHLFromRelObject = function addHLFromRelObject(relObjectName){
    var i=0;
    
    var rowsInHtmlTable = "";
    relObjectName = relObjectName+'_';

    var radIndex =1;
    var hlReason ='';
    while(CS.Service.config[relObjectName+i]){ 
        var radiatorString = "";
        
        var hlc = '';
        if(relObjectName=='Radiator'){
            var hlcVal = CS.getAttributeValue(relObjectName +i+":Override_Reason_0") || '';
            if(hlcVal && hlcVal!=''){
                var hlReason = CS.getAttributeValue(relObjectName +i+":Override_Reason_0") || '';
                rowsInHtmlTable+=addHLRow(radIndex, hlReason);
            }
        }
        else{
            var hlcVal = CS.getAttributeValue(relObjectName +i+":Heatloss_Required_0") || '';
            if(hlcVal && hlcVal=='No'){
                var hlReason = CS.getAttributeValue(relObjectName +i+":Heatloss_Reason_0") || '';
                rowsInHtmlTable+=addHLRow(radIndex, hlReason);
            }
        }
        
        if(CS.Service.config[relObjectName +i]){i++;radIndex++;} else break;
    } 
    
    return rowsInHtmlTable;
}

window.addHLRow =  function addHLRow(radIndex,hlReason){
        var tableRow = "<tr>";
        tableRow+="<td>"+radIndex+"</td>";
        tableRow+="<td>"+hlReason+"</td>";
        tableRow+="</tr>";
        return tableRow;

    };

window.addRadiatorRow =  function addRadiatorRow(radIndex,radiator, fittingPack, roomName, roomLocation, radPrice, showPrice){
        
        var tableRow = "<tr>";
        tableRow+="<td>"+radIndex+"</td>";
        tableRow+="<td>"+radiator+"</td>";
        if(showPrice){
            tableRow+="<td>"+radPrice+"</td>";
        }
        tableRow+="<td>"+fittingPack+"</td>";
        tableRow+="<td>"+roomName+"</td>";
        tableRow+="<td>"+roomLocation+"</td>";

        tableRow+="</tr>";

        return tableRow;

    };
    
window.radiatorExistis = function radiatorExistis(){
    var exists = false;
    if(CS.Service.config["Radiator_0:Radiator_Category_0"]!=undefined){
        exists = true;
    }
    return exists;
}

window.actualRadiatorExistis = function actualRadiatorExistis(){
    var exists = false;
    if(CS.Service.config["Actual_Radiator_0:Heatloss_Required_0"]!=undefined){
        exists = true;
    }
    return exists;
}   
    
window.addAsbestosLocation = function addAsbestosLocation(){
        var i=0;
        var asbestosBox="<span class='warning'><p class='bold'>Asbestos Identified</p><ol>";
        while(CS.Service.config['Asbestos_Location_'+i]){ 
            var asbestosLocationString = 'Asbestos_Location_'+i;
            var asbestosLocationString = "";
            try {
                asbestosLocationString = CS.Service.config["Asbestos_Location_"+i+":Asbestos_Location_0"].attr["cscfga__Display_Value__c"];
            }
            catch(err) {
                asbestosLocationString = "--None--";
            }
            
            asbestosBox+=addAsbestosRow(asbestosLocationString);
            if(CS.Service.config['Asbestos_Location_'+i]){i++} else break;
             
             
             CS.Log.warn(asbestosBox);
    } 
    asbestosBox+="</ol></span>";
    return asbestosBox;
}
window.addAsbestosRow =  function addAsbestosRow(asbestosLocation){
        var asbRow = "<li>"+asbestosLocation+"</li>";
        return asbRow;

};

window.addBoilerPlusReason = function addBoilerPlusReason() {
    console.log("addBoilerPlusReason()");
    var val =CS.getAttributeValue("Boiler_Plus_Reason_0","String");
    var msg='';
    console.log(val);
    if(!val || val=='' || val=='Not applicable' || val=="--Select--") {
        return '';
    }
    //needs to be level2 to be split but style of Level1
    var str="<tr><td colspan='3' class='Level2'><span class='Level1'>Boiler Plus Policy</span><td></tr>";

    if(val=="Cost" || val=="Disruption") {
        msg="We have explained the Boiler plus requirements as well as the benefits of having one of the qualifying measures installed. You have requested not to accept a qualifying measure. At some future point your local authority (if appropriate) or a Gas Safe inspector may require this to be installed.";
    }

    if(val=="Existing Product") {
        msg="Your system already contains controls which meet the requirements for Boiler plus, so no additional products are required";
    }
    if(val=="Included") {
        msg="Your Heating system is compliant with the Boiler plus legislation as you have selected a compatible control which will help reduce your energy usage";
    }
    //finish the string
    str+="<tr><td colspan='3'>"+msg+"</td></tr>";

    console.log(str);
    return str;
}

// Functions regarding new asbestos suspected record handling (TS: 03.05.2017)

window.createSuspectAsbestosMaterialForm = function createSuspectAsbestosMaterialForm() {
  // needed data for the form:
  // - Customer name (string)
  // - Customer address (string)
  // - Quote reference (string)
  // - Visit Date (string)
  // - HSA name (string)
  // - Have Artex ceiling coatings been identified (bool)
  // - Suspect materials records (array)
  //    * ID (int)
  //    * Date (string)
  //    * Reference (string)
  //    * Room (string)
  //    * Type (string)
  //    * Disturbed (string)
  //    * Sample Req (string)
  //    * Sample location (string)
  // - Sample History (array)
  //    * ID (int)
  //    * Date (string)
  //    * Result (string)
  //    * Action (string)

  function todayDate() {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    if(dd<10) {
        dd='0'+dd
    } 

    if(mm<10) {
        mm='0'+mm
    } 

    return dd+'/'+mm+'/'+yyyy;
  }

  function formatDate(d){
        var today = new Date(d);
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();

        if(dd<10) {dd='0'+dd} 
        if(mm<10) {mm='0'+mm} 

        return dd+'/'+mm+'/'+yyyy;
  }
  
  // constants
  var today = new Date();
  var BRITISH_GAS_LOGO  = '<img class="bgLogo" src="BG_logo_s.png">';
  var SCOTTISH_GAS_LOGO = '<img class="bgLogo" src="SG_logo_s.png">';
  
  var BRITISH_BRAND_NAME = "British Gas";
  var SCOTTISH_BRAND_NAME = "Scottish Gas";
  
  var ARTEX_SECTION_HTML   = "<h3>Artex Ceiling Coatings</h3>" +
                             "<p>Artex ceiling coatings have been identified in the vicinity of " +
                             "the scheduled work. We are able to safely work in this environment in line with British Gas technical operational procedures P3</p>";
  
  
  var customerName      = "Developer Demo";
  var customerAddress   = "Developer Street";
  var customerStreet    = "Customer Street 9"
  var customerCity      = "Customer City";
  var customerCounty    = "Customer County";
  var customerPostcode  = "Customer Postcode";
  var visitDate         = formatDate(today);
  var hsaName           = quoteHsaName;
  var hasArtex          = CS.getAttributeValue('Artex_Identified_0') === 'Disturbed';
  //var hasAsbestos       = CS.getAttributeValue('Asbestos_Identified_0') === 'Yes';

  var appointmentId = CS.getAttributeValue('Appointment_Id_0');
  var opportunityId  = CS.getAttributeValue('CHI_Lead_Id_0');
  var isLogoBg = !(CS.getAttributeValue('Geographic_Region_0') === 'Scotland');
  var logoToShow = isLogoBg ? BRITISH_GAS_LOGO : SCOTTISH_GAS_LOGO;
  var brandName = isLogoBg ? BRITISH_BRAND_NAME : SCOTTISH_BRAND_NAME;
  var artexSection = hasArtex ? ARTEX_SECTION_HTML : '';


  var getsuspectMaterialsRecordsTableHtml = function(suspmat) {
      if (suspmat === null || suspmat.length === 0) { return "<p>No additional suspect material was identified</p>"; }
     var str='<h3>Suspect asbestos containing materials records</h3>';
      str+='<p>This table is a history of suspect asbestos containing materials identified at the property.</p>';
      str+= '<table>';
      str    += '  <tr> ';
      str    += '    <th>ID</th>';
      str    += '    <th>Date</th>';
      str    += '    <th>Reference</th>';
      str    += '    <th>Room</th>';
      str    += '    <th>Type</th>';
      str    += '    <th>Wil it be<br>disturbed</th>';
      str    += '    <th>Sample Req</th>';
      str    += '    <th>Sample location</th>';
      str    +='     <th>Action</th>';
      str    += '  </tr>';
      
      for (var i = 0; i < suspmat.length; ++i) {
          str += '<tr>';
          str += '  <td>' + suspmat[i].matId + '</td>';
          str += '  <td>' + formatDate(suspmat[i].matDate) + '</td>';
          str += '  <td>' + suspmat[i].quoteReference + '</td>';
          str += '  <td>' + suspmat[i].room + '</td>';
          str += '  <td>' + suspmat[i].matType + '</td>';
          str += '  <td>' + suspmat[i].disturbed + '</td>';
          str += '  <td>' + suspmat[i].sampleReq + '</td>';
          str += '  <td>' + suspmat[i].sampleLoc + '</td>';
          str += '  <td>' + suspmat[i].action + '</td>';
          str += '</tr>';
      }
      
      str += '</table>';
      
      return str;
      
  };
  
  var getSampleHistoryTableHtml = function(samphist) {
      if (samphist === null || samphist.length === 0) { return "<p>No sample history records available</p>"; }
      var str='<h3>Sample History Records</h3>';
      str+='<p>The following records show the outcome of samples taken for the records above where a sampe was required.</p>';
      str+= '<table>';
      str    += '  <tr> ';
      str    += '    <th>ID</th>';
      str    += '    <th>Date</th>';
      str    += '    <th>Result</th>';
      str    += '    <th>Action</th>';
      str    += '  </tr>';
      
      for (var i = 0; i < samphist.length; ++i) {
          str += '<tr>';
          str += '  <td>' + samphist[i].sampleId + '</td>';
          str += '  <td>' + samphist[i].sampleDate + '</td>';
          str += '  <td>' + samphist[i].result + '</td>';
          str += '  <td>' + samphist[i].sampleAction + '</td>';
          str += '</tr>';
      }
      
      str += '</table>';
      
      return str;
  }



  // TODO: Add some kind of the unique ID to this product config to prevent from duplicating them if the quote gets cloned

  var suspectMaterialsRecords = [];
  var sampleHistoryRecords = [];

  for (var i = 0; i < CS.Service.config.Suspected_Materials_0.relatedProducts.length; ++i) {

    var relProdName = "Suspected_Materials_" + i + ":";

    var suspectMaterialsRecord = {
        "matId":            i, // This Id joins a sample and a suspectMat
        "matDate":          CS.getAttributeValue(relProdName + 'Date_0'),
        "matType":          CS.getAttributeValue(relProdName + 'Type_0'),
        "disturbed":        CS.getAttributeValue(relProdName + 'Disturbed_0'),
        "sampleReq":        CS.getAttributeValue(relProdName + 'SampleReq_0'),
        "sampleLoc":        CS.getAttributeValue(relProdName + 'Sample_Location_0'),
        "quoteReference":   CS.getAttributeValue(relProdName + 'Reference_0') || '',
        "room":             CS.getAttributeValue(relProdName + 'Room_0'),// This is a quote reference from the quote that created this record (it's here because the ref could have came from another quote))
        "action":           CS.getAttributeValue(relProdName + 'Action_type_0')
    };

    var sampleHistory = {
        "sampleId":         i, // This Id joins a sample and a suspectMat
        "sampleDate":       CS.getAttributeValue(relProdName + 'Sample_Date_0'),   // This is the date when the sample arrived from the lab -- add it to product definition,
        "result":           CS.getAttributeValue(relProdName + 'Sample_Result_0'),
        "sampleAction":     CS.getAttributeValue(relProdName + 'Action_0')
    }

    suspectMaterialsRecords.push(suspectMaterialsRecord);

    if (suspectMaterialsRecord.sampleReq == "Yes") { 
        sampleHistoryRecords.push(sampleHistory);   
    }

    
  }
  
  if (navigator.device) {
      
    var sendToPlugin = function (inparam) {
         var appointment = inparam.app;
         var opportunity = inparam.opp;
         console.log("Appointment: " + appointment);
         console.log("Oppty:" + opportunity);
         
         if ( appointment && (typeof appointment) == "string") {
             appointment = JSON.parse(appointment);
         }
         if (opportunity && (typeof opportunity) == "string") {
             opportunity = JSON.parse(opportunity);
         }

         var offlineOutput = {
            "customerName": "Customer Name",
            "customerStreet": opportunity.Install_Address_Street__c ? opportunity.Install_Address_Street__c : '',
            "customerCity": opportunity.Install_Address_City__c ? opportunity.Install_Address_City__c : '',
            "customerCounty": opportunity.Install_Address_County__c ? opportunity.Install_Address_County__c : '',
            "customerPostcode": opportunity.Install_Postcode__c ? opportunity.Install_Postcode__c : '',
            "quoteReference": CS.getAttributeValue('Quote_Reference_0') || '', // This is current quote reference
            "visitDate": visitDate,
            "hsaName": hsaName,
            "suspectMaterials": getsuspectMaterialsRecordsTableHtml(suspectMaterialsRecords),
            "sampleHistory": getSampleHistoryTableHtml(sampleHistoryRecords),
            "brandname1": brandName,
            "brandname2": brandName,
            "logoPng": logoToShow,
            "artexSection": artexSection
         };
      
         var serializedOutputForOffline = JSON.stringify(offlineOutput);
         serializedOutputForOffline = serializedOutputForOffline.split('&amp;').join('&');
         serializedOutputForOffline = serializedOutputForOffline.split('&pound;').join('\u00A3');
         
         cordova.exec(
             function(res) {  console.log("ret: "+res); }, 
             function(er) { console.log("err: "+er); }, 
             "DSAHTMLTemplatePlugin", 
             "openTemplate", 
             ["SuspectedMaterialsForm", serializedOutputForOffline, null, true, true]);
         
     };
      
     CS.DB.smartQuery("SELECT {Appointment__c:_soup} FROM {Appointment__c} WHERE {Appointment__c:Id} = '" + appointmentId + "'").then(function(qr) {
        return qr.getAll().then(function (results) {
               
            var outparam = {};

            if (results.length > 0) {
                CS.Log.warn(results[0][0]);
                var appointment = results[0][0];
                return CS.DB.smartQuery("SELECT {Opportunity:_soup} FROM {Opportunity} WHERE {Opportunity:Id} = '" + appointment.Opportunity__c + "'").then(function(qr) {
                    return qr.getAll().then(function (r) {
                        
                        outparam.app = appointment;
                        outparam.opp = {}; 
                        if (r && r.length > 0) {
                            CS.Log.warn('***** Opportunity retrieved: ' + r.length);
                            CS.Log.warn(r[0][0]);
                            outparam.opp = r[0][0];
                        }
                        sendToPlugin(outparam);
                    });
                });
            } else {
                CS.Log.warn('***** No Appointment retrieved!!!');
                sendToPlugin(params);
            }
        });
     }).fail(function(error) {
         CS.Log.error(error);
     });

         
  } else {
      
      var output = {
        "customerAddress": customerAddress,
        "quoteReference": CS.getAttributeValue('Quote_Reference_0') || '', // This is current quote reference
        "visitDate": visitDate,
        "hsaName": hsaName,
        "hasArtex": hasArtex,
        "logoBG": isLogoBg,
        "suspectMaterialsRecords": suspectMaterialsRecords,
        "sampleHistoryRecords": sampleHistoryRecords
      };
      
      var serializedOutputForOnline = btoa(unescape(encodeURIComponent(JSON.stringify(output))));
      
      UISupport.AttachTempFileReturnId(appointmentId,
        "TEMP_AsbestosForm.txt",
        serializedOutputForOnline,
        function(result, event) {
            if (event.status) {
                window.open("/apex/CS_SuspectedAsbestosMaterialRecord?attId=" + result
                                                                  + "&appId=" + appointmentId);
            }
        });
  }
}
