//
//  ViewController.swift
//  iOSwiftDemoApp
//
//  Created by Ales Teska on 24.4.18.
//

import UIKit
import SeaCatClient

class ViewController: UIViewController {

    @IBOutlet weak var clientTagLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    var taskTimer: Timer!
    
    override func viewWillAppear(_ animated: Bool) {
        self.onStateChanged();
        self.onClientIdChanged();
        super.viewWillAppear(animated);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (!SeaCatClient.isReady())
        {
            performSegue(withIdentifier: "SeaCatSplashSeque", sender: self);
            return;
        }
        
        self.taskTimer = Timer.scheduledTimer(timeInterval:1.0, target:self, selector:#selector(self.onTaskTimer), userInfo:nil, repeats:true);
        SeaCatClient.addObserver(self, selector:#selector(self.onStateChanged), name:SeaCat_Notification_StateChanged);
        SeaCatClient.addObserver(self, selector:#selector(self.onClientIdChanged), name: SeaCat_Notification_ClientIdChanged);
        
        super.viewDidAppear(animated);
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        self.taskTimer.invalidate();
        self.taskTimer = nil;

        SeaCatClient.removeObserver(self);
    }
    
    
    @objc func onStateChanged()
    {
        OperationQueue.main.addOperation {
            self.stateLabel.text = SeaCatClient.getState();
        }
    }
    
    @objc func onClientIdChanged()
    {
        OperationQueue.main.addOperation {
            self.clientTagLabel.text = SeaCatClient.getClientTag();
        }
    }

    @objc func onTaskTimer()
    {
        self.onStateChanged();
        SeaCatClient.ping(self as SeaCatPingDelegate);
        
        DispatchQueue.global().async() {
            self.taskURLSession_GET()
        }
    }

    func taskURLSession_GET()
    {
        let url = URL(string: "http://evalhost.seacat/hello");
        let configuration = SeaCatClient.getNSURLSessionConfiguration();

        let session = URLSession(configuration: configuration!, delegate:self as? URLSessionDelegate, delegateQueue:nil);
        
        var request = URLRequest(url: url!);
        request.httpMethod = "GET";
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                OperationQueue.main.addOperation {
                    self.resultLabel.text = String(format:"Status code: %d", arguments:[statusCode]);
                }
            }
        }
        
        task.resume();
    }
}

extension ViewController: SeaCatPingDelegate
{
    func pong(_ pingId: Int32) {
        OperationQueue.main.addOperation {
            self.pingLabel.text = String(format:"Ping received: %d", arguments:[pingId]);
        }
    }
}
