//
//  SplashViewController.swift
//  iOSwiftDemoApp
//
//  Created by Ales Teska on 24.4.18.
//

import UIKit
import SeaCatClient

class SplashViewController: UIViewController {
    
    @IBOutlet weak var clientTagLabel: UILabel!
    @IBOutlet weak var stateLabel: UIBarButtonItem!
    var periodicTimer: Timer!
    
    override func viewWillAppear(_ animated: Bool) {
        if (SeaCatClient.isReady())
        {
            self.dismiss(animated: true, completion: nil);
        }

        return super.viewWillAppear(animated);
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        SeaCatClient.addObserver(self, selector:#selector(self.onStateChanged), name:SeaCat_Notification_StateChanged);
        self.periodicTimer = Timer.scheduledTimer(timeInterval:1.0, target:self, selector:#selector(self.onStateChanged), userInfo:nil, repeats:true);
        self.onStateChanged();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SeaCatClient.removeObserver(self);
        
        self.periodicTimer.invalidate();
        self.periodicTimer = nil;
        
        super.viewWillDisappear(animated);
    }
    
    @objc func onStateChanged()
    {
        OperationQueue.main.addOperation {
            self.stateLabel.title = SeaCatClient.getState();
            self.clientTagLabel.text = SeaCatClient.getClientTag();

            if (SeaCatClient.isReady())
            {
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
    
    @IBAction func onResetPressed(_ sender: Any) {
        //TODO: AlertController
        SeaCatClient.reset();
    }
    
}
