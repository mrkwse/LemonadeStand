//
//  ViewController.swift
//  LemonadeStand
//
//  Created by Mark Woosey on 15/01/2015.
//  Copyright (c) 2015 Mark Woosey. All rights reserved.
//

import UIKit

var cashBalance:Int = 10                // Balance of available cash
var cashCredit:[Int] = [0, 0]           // Price of lemons, ice to purchase
var currentLemons:Int = 0               // Current number of lemons
var currentIceCubes:Int = 0             // Current number of ice cubes
var lemonsToPurchase:Int = 0            // Number of lemons to purchase
var iceCubesToPurchase:Int = 0          // Number of ice cubes to purchase
var lemonadeMixture:[Int] = [0, 0]      // Mixture of lemonade (index 0:index 1 == lemons:ice == lemonsToMix:iceCubesToMix)


class ViewController: UIViewController {

    @IBOutlet weak var currentCashLabel: UILabel!
    @IBOutlet weak var currentLemonsLabel: UILabel!
    @IBOutlet weak var currentIceCubesLabel: UILabel!
    @IBOutlet weak var lemonsToPurchaseLabel: UILabel!
    @IBOutlet weak var iceCubesToPurchaseLabel: UILabel!
    @IBOutlet weak var lemonsToMixLabel: UILabel!
    @IBOutlet weak var iceCubesToMixLabel: UILabel!
    
    @IBOutlet weak var lemonsToPurchaseStepperValue: UIStepper!
    
    @IBOutlet weak var iceCubesToPurchaseStepperValue: UIStepper!
    
    @IBOutlet weak var lemonsToMixStepperValue: UIStepper!
    @IBOutlet weak var iceCubesToMixStepperValue: UIStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func lemonsToPurchaseStepper(sender: UIStepper) {
        lemonsToPurchase = Int(lemonsToPurchaseStepperValue.value)
        cashCredit[0] = 2 * lemonsToPurchase
        updatePurchaseSteppers()
        updateMixSteppers()
        updateLemonText()
        updateCashText()
    }
    
    @IBAction func iceCubesToPurchaseStepper(sender: UIStepper) {
        iceCubesToPurchase = Int(self.iceCubesToPurchaseStepperValue.value)
        cashCredit[1] = iceCubesToPurchase
        updatePurchaseSteppers()
        updateMixSteppers()
        updateIceCubeText()
        updateCashText()
    }
    
    @IBAction func lemonsToMixStepper(sender: UIStepper) {
        lemonadeMixture[0] = Int(self.lemonsToMixStepperValue.value)
        updateMixSteppers()
        updateLemonText()

    }
    
    @IBAction func iceCubesToMixStepper(sender: UIStepper) {
        lemonadeMixture[1] = Int(self.iceCubesToMixStepperValue.value)
        updateMixSteppers()
        updateIceCubeText()

    }
    
    @IBAction func beginDayButton(sender: UIButton) {
        cashBalance -= (cashCredit[0] + cashCredit[1])
        cashCredit = [0, 0]
        currentLemons += lemonsToPurchase
        currentIceCubes += iceCubesToPurchase
        lemonsToPurchase = 0
        iceCubesToPurchase = 0
        let results = sellLemonade(lemonadeMixture, availableLemons: currentLemons, availableIce: currentIceCubes)
//        lemonadeMixture = [0, 0]
        currentLemons = results.lemons
        currentIceCubes = results.ice
        cashBalance += results.profit
        updatePurchaseSteppers()
        updateMixSteppers()
        updateLemonText()
        updateIceCubeText()
        updateCashText()
    }
    
    func updateLemonText() {
        self.currentLemonsLabel.text = "\(currentLemons + lemonsToPurchase) Lemons"
        self.lemonsToPurchaseLabel.text = "Lemons ($2): \(lemonsToPurchase)"
        self.lemonsToMixLabel.text = "Lemons: \(lemonadeMixture[0])"
    }
    
    func updateIceCubeText() {
        self.currentIceCubesLabel.text = "\(currentIceCubes + iceCubesToPurchase) Ice Cubes "
        self.iceCubesToPurchaseLabel.text = "Ice Cubes ($1): \(iceCubesToPurchase)"
        self.iceCubesToMixLabel.text = "Ice Cubes: \(lemonadeMixture[1])"
    }
    
    func updatePurchaseSteppers() {
        // Lemons
        lemonsToPurchaseStepperValue.value = Double(lemonsToPurchase)
//        lemonsToPurchaseStepperValue.maximumValue = Double(cashBalance/2)
        lemonsToPurchaseStepperValue.maximumValue = Double(lemonsToPurchase +  ((cashBalance - (cashCredit[0] + cashCredit[1]))/2))
        
        // Ice
        iceCubesToPurchaseStepperValue.value = Double(iceCubesToPurchase)
//        iceCubesToPurchaseStepperValue.maximumValue = Double(cashBalance)
        iceCubesToPurchaseStepperValue.maximumValue = Double(iceCubesToPurchase + (cashBalance - (cashCredit[0] + cashCredit[1])))
    }
    
    func updateMixSteppers() {
        // Lemons
        lemonsToMixStepperValue.value = Double(lemonadeMixture[0])
        lemonsToMixStepperValue.maximumValue = Double(currentLemons + lemonsToPurchase)
        if (Double(lemonadeMixture[0]) > lemonsToMixStepperValue.maximumValue) {
            lemonadeMixture[0] = Int(lemonsToMixStepperValue.value)
        }
        
        // Ice
        iceCubesToMixStepperValue.value = Double(lemonadeMixture[1])
        iceCubesToMixStepperValue.maximumValue = Double(currentIceCubes + iceCubesToPurchase)
        if (Double(lemonadeMixture[1]) > iceCubesToMixStepperValue.maximumValue) {
            lemonadeMixture[1] = Int(iceCubesToMixStepperValue.maximumValue)
        }
    }
    
    func updateCashText() {
        currentCashLabel.text = "$\(cashBalance - (cashCredit[0] + cashCredit[1]))"
    }

    func sellLemonade(recipe:[Int], availableLemons:Int, availableIce:Int) -> (profit:Int, lemons:Int, ice:Int) {
        var final = (profit: 0, lemons: availableLemons, ice: availableIce)
        var customerTaste:Int = 0
        var recipeTaste:Int = 0
        if (Double(recipe[0]) / Double(recipe[1]) < 1) {
            recipeTaste = 1
        } else if (Double(recipe[0]) / Double(recipe[1]) == 1) {
            recipeTaste = 2
        } else if (Double(recipe[0]) / Double(recipe[1]) > 1) {
            recipeTaste = 3
        }
        
        println("Recipe is \(recipeTaste)")
        
        for var numberOfCustomers = Int(arc4random_uniform(UInt32(100))); numberOfCustomers > 0; --numberOfCustomers {
            println("Shop open!")
            if (final.lemons >= recipe[0] && final.ice >= recipe[1]) {
                let randomTaste:Double = Double(arc4random()) / Double(UINT32_MAX)
                
                if (randomTaste < 0.4) {
                    customerTaste = 3
                } else if (randomTaste > 0.6) {
                    customerTaste = 1
                } else {
                    customerTaste = 2
                }
                
                if (recipeTaste == customerTaste) {
                    final.profit += (2 * recipe[0]) + recipe[1] + 1
                    final.lemons -= recipe[0]
                    final.ice -= recipe[1]
                    println("Customers remaining: \(numberOfCustomers), preference: \(randomTaste):[\(customerTaste)], paid $\((2 * recipe[0]) + recipe[1] + 1)")
                } else {
                                        println("Customers remaining: \(numberOfCustomers), preference: \(randomTaste):[\(customerTaste)], no purchase")
                }
            } else {
                println("Out of lemons")
                numberOfCustomers = 0
            }
            
        }
        
            
        return final
    }

}
