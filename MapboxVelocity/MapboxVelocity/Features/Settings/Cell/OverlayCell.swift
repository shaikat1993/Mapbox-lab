//
//  OverlayCell.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit

class OverlayCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var seperatorView: UIView!
    
    var onToggle: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    private func setupAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(hex: "#adc6ff")
        iconImageView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        iconImageView.layer.cornerRadius = 10
        iconImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .white
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor = UIColor(hex: "#8b90a0")
        
        toggleSwitch.onTintColor = UIColor(hex: "#06300b")
    }
    
    func configure(with overlay: TechnicalOverlay,
                   isLast: Bool = false) {
        iconImageView.image = UIImage(systemName: overlay.icon)
        titleLabel.text = overlay.title
        subtitleLabel.text = overlay.subTitle
        toggleSwitch.isOn = overlay.isEnabled
        seperatorView.isHidden = isLast
    }
    
    @IBAction func toggleChanged(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
}
