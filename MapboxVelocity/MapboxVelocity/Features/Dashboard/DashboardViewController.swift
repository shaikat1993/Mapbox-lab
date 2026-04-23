//
//  DashboardViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//
import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#121212")
        title = "Dashboard"
        buildCards()
    }
    
    private func buildCards() {
        let card1 = CardView()
        let card2 = CardView()
        let card3 = CardView()
        let card4 = CardView()

        [card1,
         card2,
         card3,
         card4].forEach { card in
            card.backgroundColor      = UIColor(hex: "#fafafa")
            card.roundedCorners       = .allCorners
            card.roundedCornerRadius  = 16
            card.layer.shadowColor    = UIColor.black.cgColor
            card.layer.shadowOpacity  = 0.4
            card.layer.shadowRadius   = 12
            card.layer.shadowOffset   = CGSize(width: 0, height: 4)

            stackView.addArrangedSubview(card)
        }
    }
}
