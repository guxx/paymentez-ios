//
//  ListCardsTableViewController.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 09/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

protocol CardSelectedDelegate
{
    func cardSelected(card:PaymentezCard?)
}

class ListCardsTableViewController: UITableViewController {

    var cardList = [PaymentezCard]()
    var cardSelectedDelegate:CardSelectedDelegate?
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTable()

    }
    func refreshTable()
    {
        self.cardList.removeAll()
        
        MyBackendLib.listCard(uid: UserModel.uid) { (cardList) in
            self.cardList = cardList!
            DispatchQueue.main.async {
               self.tableView.reloadData();
            }
            
        }
        
        
        
        /*PaymentezSDKClient.listCards(UserModel.uid) { (error, cardList) in
            
            if error == nil
            {
                self.cardList = cardList!
                
                
            }
            
            
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cardList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        
        let card = self.cardList[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "****" + card.termination!
        cell.detailTextLabel!.text = "\(card.expiryMonth!)/\(card.expiryYear!)"
        cell.imageView?.image = card.getCardTypeAsset()
        // Configure the cell...

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let card  = self.cardList[(indexPath as NSIndexPath).row]
        self.cardSelectedDelegate?.cardSelected(card: card)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    // MARK: - Navigation

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let card = self.cardList[(indexPath as NSIndexPath).row]
        var actions = [UITableViewRowAction]()
        if card.status == "review"
        {
            let editAction = UITableViewRowAction(style: .normal, title: "Verify") { (rowAction, indexPath) in
                
                
                let alertController = UIAlertController(title: "Verificar ", message: "Especifica el valor: Monto o valor", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                    textField.placeholder = "Valor"
                })
                let verifyActionAmount = UIAlertAction(title: "Verificar por Monto", style: .default, handler: { (alertaction) in
                    MyBackendLib.verifyTrx(uid: UserModel.uid, transactionId: card.transactionId!, type: 0, value: (alertController.textFields?[0].text!)!, callback: { (error, verified) in
                        
                        if verified
                        {
                            let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(card.transactionId!), preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                            })
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        }
                        else
                        {
                            let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                            })
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        }
                        
                    })
                })
                let verifyActionAmount2 = UIAlertAction(title: "Verificar por Código", style: .default, handler: { (alertaction) in
                    MyBackendLib.verifyTrx(uid: UserModel.uid, transactionId: card.transactionId!, type: 1, value: (alertController.textFields?[0].text!)!, callback: { (error, verified) in
                        
                        if verified
                        {
                            let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(card.transactionId!), preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                            })
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        }
                        else
                        {
                            let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                            })
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        }
                        
                    })
                })
                let verifyClose = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alertaction) in
                    
                })
                alertController.addAction(verifyActionAmount)
                alertController.addAction(verifyActionAmount2)
                alertController.addAction(verifyClose)
                self.present(alertController, animated: true
                    , completion: {
                        
                })
                
                //DEV BACKEND WITH VERIFY WITH AMOUNT
            }
            editAction.backgroundColor = .blue
            actions.append(editAction)
        }
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let card = self.cardList[(indexPath as NSIndexPath).row]
            
            MyBackendLib.deleteCard(uid: UserModel.uid, cardToken: card.token!, callback: { (deleted) in
                if(deleted)
                {
                    self.refreshTable()
                }
            })

        }
        deleteAction.backgroundColor = .red
        actions.append(deleteAction)
        return actions
    }
    
    @IBAction func presentAddVC(_ sender:Any?){
        
        
        let alertController = UIAlertController(title: "Selecciona el tipo de vista", message: nil, preferredStyle: .actionSheet)
        
        
        let alertAction = UIAlertAction(title: "Widget in Custom View", style: UIAlertActionStyle.default) { (_) in
            self.performSegue(withIdentifier: "widgetSegue", sender: self)
        }
        let alertAction2 = UIAlertAction(title: "View Controller (Push)", style: UIAlertActionStyle.default) { (_) in
            self.navigationController?.pushPaymentezViewController(delegate: self, uid: UserModel.uid, email: UserModel.email)
        }
        let alertAction3 = UIAlertAction(title: "View Controller (Modal)", style: UIAlertActionStyle.default) { (_) in
             self.presentPaymentezViewController(delegate: self, uid: UserModel.uid, email: UserModel.email)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(alertAction2)
        alertController.addAction(alertAction3)

        self.present(alertController, animated: true, completion: nil)
        
       
        
    }
    
   
    
    
}

extension ListCardsTableViewController: PaymentezCardAddedDelegate{
    
    func cardAdded(_ error: PaymentezSDKError?, _ cardAdded: PaymentezCard?) {
        //handle status
        if cardAdded != nil{
            let alertController = UIAlertController(title: "Card Status", message: cardAdded?.status, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
            self.refreshTable()
        }else if  let err = error {
            let alertController = UIAlertController(title: "error", message: err.type, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
        
        
    }
    func viewClosed() {
        //handle closed
    }
}

