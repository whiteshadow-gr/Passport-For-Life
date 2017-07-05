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

// MARK: Class

/// The class responsible for the landing screen
internal class PassportViewController: UIViewController, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {

    // MARK: - Variables
    
    /// The badges to show
    private var badges: [UIImage] = []
    
    /// The profile, used in PHATA table
    private var profile: HATProfileObject?
    
    /// The sections of the table view
    private let sections: [[String]] = [["Name", "Info", "Contact Info"], ["Nationality"], ["Skills"], ["Education"], ["Activities"], ["Grades"]]
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    private var authoriseVC: AuthoriseUserViewController?
    
    private let location: UpdateLocations = UpdateLocations.shared
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the circle progress bar view
    @IBOutlet private weak var ringProgressBar: RingProgressCircle!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var tableView: UITableView!
    /// An IBOutlet for handling the hello label on the top of the screen
    @IBOutlet private weak var helloLabel: UILabel!
    
    // MARK: - IBActions
    
    /**
     Shows a pop up info about the data services
     
     - parameter sender: The object that called this method
     */
    @IBAction func showInfoButtonAction(_ sender: Any) {
        
        self.showInfoViewController(text: "Rumpel Lite's Data Services are all the neat things you can do with your HAT data. Pull your data in with Data Plugs, and make it useful to you with Data Services.")
    }
    
    // MARK: - Collection View methods
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.badgesCell, for: indexPath) as? BadgesCollectionViewCell
        
        return BadgesCollectionViewCell.setUpCell(badgeImage: self.badges[indexPath.row], cell: cell!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.badges.count
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.badges = BadgesCollectionViewCell.createBadges()
        
        self.ringProgressBar.ringColor = .white
        self.ringProgressBar.ringRadius = 45
        self.ringProgressBar.ringLineWidth = 4
        self.ringProgressBar.animationDuration = 0.2
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUp), name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo), object: nil)
        
        // pin header view of collection view to the top while scrolling
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)!.sectionHeadersPinToVisibleBounds = true
    }
    
    /**
     If the profile table has been created get the profile values from HAT
     
     - parameter dictionary: The dictionary returned from hat
     - parameter renewedToken: The new token returned from hat
     */
    func tableCreated(dictionary: Dictionary<String, Any>, renewedToken: String?) {
        
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
    }
    
    /**
     Gets profile from hat and saves it to a local variable
     
     - parameter receivedProfile: The received HATProfileObject from HAT
     */
    private func getProfile(receivedProfile: HATProfileObject) {
        
        self.profile = receivedProfile
    }
    
    /**
     Logs the error occured
     
     - parameter error: The HATTableError occured
     */
    private func logError(error: HATTableError) {
        
        self.profile = HATProfileObject()
        
        switch error {
        case .tableDoesNotExist:
            
            let tableJSON = HATJSONHelper.createProfileTableJSON()
            HATAccountService.createHatTable(userDomain: userDomain, token: userToken, notablesTableStructure: tableJSON, failed: {(error) in
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            })(
                
                HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: Constants.HATTableName.Profile.name, sourceName: Constants.HATTableName.Profile.source, authToken: userToken, successCallback: tableCreated, errorCallback: logError)
            )
        default:
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.ringProgressBar.isHidden = true
        
        HATPhataService.getProfileFromHAT(userDomain: userDomain, userToken: userToken, successCallback: getProfile, failCallback: logError)
        
        func success(token: String?) {
            
            if token != "" && token != nil {
                
                _ = KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: token!)
                _ = KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.setTrue)
                
                self.authoriseVC?.removeViewController()
                self.authoriseVC = nil
            }
        }
        
        func failed() {
            
            NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.networkMessage), object: "Unauthorized. Please sign out and try again.")
            _ = KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.expired)
            
            self.authoriseVC = AuthoriseUserViewController.setupAuthoriseViewController(view: self.view)
            self.authoriseVC?.completionFunc = success
            // addauthoriseVCthe page view controller to self
            self.addViewController(self.authoriseVC!)
        }
        
        // reset the stack to avoid allowing back
        let result = KeychainHelper.getKeychainValue(key: Constants.Keychain.logedIn)
        
        if result == "false" || userDomain == "" || userToken == "" {
            
            if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                
                self.navigationController?.pushViewController(loginViewController, animated: false)
            }
            // user logged in, set up view
        } else {
            
            self.location.setUpLocationObject(self.location, delegate: UpdateLocations.shared)
            self.location.locationManager?.requestAlwaysAuthorization()
            
            // set up elements
            let usersHAT = userDomain.components(separatedBy: ".")[0]
            self.helloLabel.text = "Hello " + usersHAT + "!"
            
            // check if the token has expired
            HATAccountService.checkIfTokenExpired(
                token: userToken,
                expiredCallBack: failed,
                tokenValidCallBack: success,
                errorCallBack: self.createClassicOKAlertWith)
            
            self.collectionView?.reloadData()
        }
        
        HATService.getSystemStatus(userDomain: userDomain, authToken: userToken, completion: updateRingProgressBar, failCallBack: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
        
        self.collectionView.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Show pop up screens
    
    /**
     Shows newbie screens
     */
    private func showNewbieScreens() {
        
        // set up the created page view controller
        if let pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "firstTimeOnboarding") as? FirstOnboardingPageViewController {
            
            pageViewController.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30), color: .blue, cornerRadius: 15)
            
            // add the page view controller to self
            self.addViewController(pageViewController)
            self.addBlurToView()
        }
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(stringToShow: text, from: self.storyboard!)
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.collectionView.frame.maxY, width: self.view.frame.width - 30, height: self.view.frame.height), color: .blue, cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                        
                        textPopUpViewController?.view.frame = CGRect(x: weakSelf.view.frame.origin.x + 15, y: weakSelf.collectionView.frame.origin.y, width: weakSelf.view.frame.width - 30, height: weakSelf.view.frame.height)
                },
                    completion: { _ in return }
                )
            }
        }
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    // MARK: - Update ring progress bar
    
    /**
     Updates the system info on the top of the home screen view controller
     
     - parameter data: The objects received from the server
     */
    private func updateRingProgressBar(from data: [HATSystemStatusObject], renewedUserToken: String?) {
        
        if !data.isEmpty {
            
            self.helloLabel.text = "Hello " + userDomain.components(separatedBy: ".")[0] + "!"
            
            self.ringProgressBar.isHidden = false
            
            var attributedString: NSAttributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(attributedText: NSAttributedString(string: "Total space " + data[2].kind.metric + " " + data[2].kind.units!)).string
            attributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(attributedText: NSAttributedString(string: "Used space " + String(describing: Int(Float(data[4].kind.metric)!.rounded())) + " " + data[4].kind.units!)).string
            
            let fullCircle = 2.0 * CGFloat(Double.pi)
            self.ringProgressBar.startPoint = -0.25 * fullCircle
            self.ringProgressBar.animationDuration = 0.2
            
            let endPoint = CGFloat(max(Float(data[6].kind.metric)!, 1.0)) / 100
            
            self.ringProgressBar.endPoint = (endPoint * fullCircle) + self.ringProgressBar.startPoint
            
            self.ringProgressBar.updateCircle(end: endPoint, animate: 0, removePreviousLayer: true)
        }
        
        // refresh user token
        _ = KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
    }
    
    // MARK: - Table view methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreCell, for: indexPath)
        
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToName, sender: self)
            } else if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToInfoSegue, sender: self)
            } else if indexPath.row == 2 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToContactInfoSegue, sender: self)
            }
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToNationalitySegue, sender: self)
            }
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToHouseholdSegue, sender: self)
            }
        } else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToEducationSegue, sender: self)
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
        
        if indexPath.section == 4 || indexPath.section == 5 {
            
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        } else {
            
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.backgroundColor = .blueLight
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.profile != nil {
            
            if segue.destination is DataSourceNameTableViewController {
                
                weak var destinationVC = segue.destination as? DataSourceNameTableViewController
                
                if segue.identifier == Constants.Segue.dataStoreToName {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is DataStoreInfoTableViewController {
                
                weak var destinationVC = segue.destination as? DataStoreInfoTableViewController
                
                if segue.identifier == Constants.Segue.dataStoreToInfoSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is DataStoreContactInfoTableViewController {
                
                weak var destinationVC = segue.destination as? DataStoreContactInfoTableViewController
                
                if segue.identifier == Constants.Segue.dataStoreToContactInfoSegue {
                    
                    destinationVC?.profile = self.profile
                }
            }
        }
    }
    
}