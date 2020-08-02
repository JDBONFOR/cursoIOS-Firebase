//
//  AuthViewController.swift
//  GoogleFirebase
//
//  Created by Juan Bonforti on 01/08/2020.
//  Copyright © 2020 Juan Bonforti. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn

class AuthViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var authStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "Autenticacion"
        
        // Analitycs events
        Analytics.logEvent("InitScreen", parameters: ["message":"integracion de Firebase completa"])
        
        // How to know if user had initialized session before
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String,
            let provider = defaults.value(forKey: "provider") as? String {
            
            authStackView.isHidden = true
            
            self.navigationController?.pushViewController(HomeViewController(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
        }
        
        // Google Auth
        GIDSignIn.sharedInstance()?.presentingViewController = self // Google page to sign in, on this viewcontroller.
        GIDSignIn.sharedInstance()?.delegate = self // Delegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authStackView.isHidden = false
    }
    
    // MARK: - Private functions
    private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType) {
        if let result = result, error == nil {
            // Create account Successfully.
            self.navigationController?.pushViewController(HomeViewController(email: result.user.email!, provider: provider), animated: true)
            
            
        } else {
            // Can't create account - show Alert
            let alertController = UIAlertController(title: "Error", message: "Se ha producido un error en la autenticacion mediante \(provider.rawValue)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    @IBAction func signUpButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
        
    }
    @IBAction func logInButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    @IBAction func googleButtonAction(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    

}

// MARK: - Extensions

extension AuthViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken,
            accessToken: user.authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                self.showHome(result: result, error: error, provider: .google)
            }
        }
    }
    
    
}

