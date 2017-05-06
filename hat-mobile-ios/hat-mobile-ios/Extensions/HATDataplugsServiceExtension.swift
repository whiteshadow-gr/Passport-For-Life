/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import HatForIOS

// MARK: Extension

extension HATDataPlugsService: UserTokenProtocol {
    
    // MARK: - Wrappers
    
    /**
     Ensure if the data plug is ready
     
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOffersReady(succesfulCallBack: @escaping (String) -> Void, tokenErrorCallback: @escaping () -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> Void {
        // notables offer
        let offerID = "32dde42f-5df9-4841-8257-5639db222e41"
        
        // set up the succesfulCallBack
        let plugReadyContinue = ensureOfferEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, tokenErrorCallback: tokenErrorCallback, failCallBack: failCallBack)
        
        func checkPlugForToken(appToken: String, renewedUserToken: String?) {
            
            self.checkSocialPlugAvailability(succesfulCallBack: plugReadyContinue, failCallBack: { (error) in
                
                failCallBack(error)
                _ = CrashLoggerHelper.dataPlugErrorLog(error: error)
            })(appToken)
        }
        
        // get token async
        HATService.getApplicationTokenFor(serviceName: "Facebook", userDomain: userDomain, token: userToken, resource: "https://social-plug.hubofallthings.com", succesfulCallBack: checkPlugForToken, failCallBack: { (error) in
            
            tokenErrorCallback()
            _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
        })
    }
    
    /**
     Ensures offer is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, tokenErrorCallback: @escaping () -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (String) -> Void {
        
        return {_ in
            
            // setup succesfulCallBack
            func offerClaimForToken(appToken: String, renewedUserToken: String?) {
                
                ensureOfferDataDebitEnabled(offerID: offerID, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)(appToken)
            }
            
            // get applicationToken async
            HATService.getApplicationTokenFor(serviceName: "MarketSquare", userDomain: userDomain, token: userToken, resource: "https://marketsquare.hubofallthings.com", succesfulCallBack: offerClaimForToken, failCallBack: { (error) in
                
                tokenErrorCallback()
                _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
            })
        }
    }
    
    /**
     Ensures offer data debit is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferDataDebitEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimDDForOffer = approveDataDebitPartial(appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: failCallBack)
            
            // ensure offer is claimed
            ensureOfferClaimed(offerID: offerID, succesfulCallBack: claimDDForOffer, failCallBack: failCallBack)(appToken)
        }
    }
    
    /**
     Ensure offer claimed
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func ensureOfferClaimed(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) ->  (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimOfferIfFailed = claimOfferWithOfferIDPartial(offerID: offerID, appToken: appToken,
                                                                  succesfulCallBack: succesfulCallBack,
                                                                  failCallBack: failCallBack)
            // ensure offer is claimed
            self.checkIfOfferIsClaimed(offerID: offerID, appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: { (error) in
                
                claimOfferIfFailed()
            })
        }
    }
    
    /**
     Claims offer for this offerID
     
     - parameter offerID: The offerID as a String
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func claimOfferWithOfferIDPartial(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (Void) -> Void {
        
        return {
            
            // claim offer
            self.claimOfferWithOfferID(offerID, appToken: appToken, succesfulCallBack: succesfulCallBack, failCallBack: { (error) in
                
                failCallBack(error)
                _ = CrashLoggerHelper.dataPlugErrorLog(error: error)
            })
        }
    }
    
    /**
     Approve data debit
     
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    class func approveDataDebitPartial(appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (_ dataDebitID: String) -> Void {
        
        return { (dataDebitID: String) in
            
            // approve data debit
            self.approveDataDebit(dataDebitID, userToken: userToken, userDomain: userDomain, succesfulCallBack: succesfulCallBack, failCallBack: { (error) in
                
                failCallBack(error)
            _ = CrashLoggerHelper.dataPlugErrorLog(error: error)
            })
        }
    }
    
    // MARK: - Create URL
    
    /**
     Creates the url to connect to
     
     - parameter socialServiceName: The name of the social service
     - parameter socialServiceURL: The url of the social service
     - returns: A ready URL as a String if everything ok else nil
     */
    public class func createURLBasedOn(socialServiceName: String, socialServiceURL: String) -> String? {
        
        if socialServiceName == "twitter" {
            
            return "https://" + userDomain + "/hatlogin?name=Twitter&redirect=" + socialServiceURL + "/authenticate/hat"
        } else if socialServiceName == "facebook" {
            
            return "https://" + userDomain + "/hatlogin?name=Facebook&redirect=" + socialServiceURL.replacingOccurrences(of: "dataplug", with: "hat/authenticate")
        }
        
        return nil
    }
    
    // MARK: - Check if data plugs are active
    
    /**
     Checks if both data plugs are active
     
     - parameter completion: The function to execute when something finishes
     */
    public class func checkDataPlugsIfActive(completion: @escaping (String, Bool) -> Void) {
        
        func isCheckmarkVisible(_ result: Bool, onSocialNetwork: String) {
            
            completion(onSocialNetwork, true)
        }
        
        /// Check if facebook is active
        func checkIfFacebookIsActive(appToken: String, renewedUserToken: String?) {
            
            // check if facebook active
            HATFacebookService.isFacebookDataPlugActive(token: appToken, successful: {_ in isCheckmarkVisible(true, onSocialNetwork: "facebook")}, failed: {_ in isCheckmarkVisible(false, onSocialNetwork: "facebook")})
        }
        
        /// Check if twitter is active
        func checkIfTwitterIsActive(appToken: String, renewedUserToken: String?) {
            
            // check if twitter active
            HATTwitterService.isTwitterDataPlugActive(token: appToken, successful: {_ in isCheckmarkVisible(true, onSocialNetwork: "twitter")}, failed: {_ in isCheckmarkVisible(false, onSocialNetwork: "twitter")})
        }
        
        // get token for facebook and twitter and check if they are active
        HATFacebookService.getAppTokenForFacebook(token: userToken, userDomain: userDomain, successful: checkIfFacebookIsActive, failed: { (error) in
        
            _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
        })
        
        HATTwitterService.getAppTokenForTwitter(userDomain: userDomain, token: userToken, successful: checkIfTwitterIsActive, failed: { (error) in
        
            _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
        })
    }
    
    // MARK: - Filter available data plugs
    
    /**
     Filters the available dataplugs down to 2, facebook and twitter
     
     - parameter dataPlugs: An array of HATDataPlugObject containing the full list of available data plugs
     - returns: A filtered array of HATDataPlugObject
     */
    public class func filterAvailableDataPlugs(dataPlugs: [HATDataPlugObject]) -> [HATDataPlugObject] {
        
        var tempDataPlugs = dataPlugs
        // remove the existing dataplugs from array
        tempDataPlugs.removeAll()
        
        // we want only facebook and twitter, so keep those
        for i in 0 ... dataPlugs.count - 1 {
            
            if dataPlugs[i].name == "twitter" || dataPlugs[i].name == "facebook" {
                
                tempDataPlugs.append(dataPlugs[i])
            }
        }
        
        return tempDataPlugs
    }
}