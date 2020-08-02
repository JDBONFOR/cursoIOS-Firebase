//
//  HomeViewController.swift
//  GoogleFirebase
//
//  Created by Juan Bonforti on 01/08/2020.
//  Copyright © 2020 Juan Bonforti. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var closeSessionButton: UIButton!
    
    private let email: String?
    private let provider: ProviderType
    
    // Constructor
    init(email: String, provider: ProviderType) {
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Inicio"
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        emailLabel.text = email
        providerLabel.text = provider.rawValue
        
        // Save user data
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
    }
    
    // MARK: - Private Functions
    private func firebaseLogOut() {
        do {
            try Auth.auth().signOut()
        } catch  {
            // Se ha producido un error.
        }
    }
    
    // MARK: - IBAction
    @IBAction func closeSessionButtonAction(_ sender: Any) {
        
        // Remove user data, to logOut session
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        
        switch provider {
        
        case .basic:
            firebaseLogOut()
        case .google:
            GIDSignIn.sharedInstance()?.signOut()
            firebaseLogOut()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
