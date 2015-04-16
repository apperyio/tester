cordova.define("com.adobe.plugins.GAPlugin", function(require, exports, module) {

    var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

    function GAPlugin() { }

    // initialize google analytics with an account ID and the min number of seconds between posting
    //
    // id = the GA account ID of the form 'UA-00000000-0'
    // period = the minimum interval for transmitting tracking events if any exist in the queue
    GAPlugin.prototype.init = function(success, fail, id, period) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'initGA', [id, period]);
    };

    // log an event
    //
    // category = The event category. This parameter is required to be non-empty.
    // eventAction = The event action. This parameter is required to be non-empty.
    // eventLabel = The event label. This parameter may be a blank string to indicate no label.
    // eventValue = The event value. This parameter may be -1 to indicate no value.
    GAPlugin.prototype.trackEvent = function(success, fail, category, eventAction, eventLabel, eventValue, dimensionData) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackEvent', [category, eventAction, eventLabel, eventValue, dimensionData]);
    };

    // log a page view
    //
    // pageURL = the URL of the page view
    GAPlugin.prototype.trackPage = function(success, fail, pageURL) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackPage', [pageURL]);
    };

    // log an exception
    //
    // exception = exception description
    // isFatal = whether exception is fatal
    GAPlugin.prototype.trackException = function(success, fail, exception, isFatal) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackException', [exception, isFatal]);
    };

    // log an transaction
    //
    // transactionId = The transaction ID with which the item should be associated
    // affiliation = An entity with which the transaction should be affiliated (e.g. a particular store)
    // name = The name of the product
    // sku = The SKU of a product
    // price = The price of a product
    // quantity = The quantity of a product
    // revenue = The total revenue of a transaction, including tax and shipping
    // currencyCode = The local currency of a transaction.
    GAPlugin.prototype.trackTransaction = function(success, fail, transactionId, affiliation, name, sku, price, quantity, revenue, currencyCode) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackTransaction',
            [
                transactionId,
                affiliation,
                name,
                sku,
                price,
                quantity,
                revenue,
                currencyCode
            ]
        );
    };

    GAPlugin.prototype.setOptOut = function(status) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setOptOut',
            [
                status
            ]
        );
    };

    // Set a custom dimension. The variable set is included with
    // the next event only. If there is an existing custom variable at the specified
    // index, it will be overwritten by this one.
    //
    // value = the value of the variable you are logging
    // index = the numerical index of the dimension to which this variable will be assigned (1 - 20)
    //  Standard accounts support up to 20 custom dimensions.
    GAPlugin.prototype.setCustomDimension = function(success, fail, index, value) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setCustomDimension', [index, value]);
    };

    // Set a custom dimension. The variable set is included with
    // the next event only. If there is an existing custom variable at the specified
    // index, it will be overwritten by this one.
    //
    // value = the value of the variable you are logging
    // index = the numerical index of the dimension to which this variable will be assigned (1 - 20)
    // Standard accounts support up to 20 custom dimensions.
    GAPlugin.prototype.setCustomMetric = function(success, fail, index, value) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setCustomMetric', [index, value]);
    };

    GAPlugin.prototype.exit = function(success, fail) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'exitGA', []);
    };

    module.exports = new GAPlugin();

});
