//
//  TableViewCell.swift
//  MapApp
//
//  Created by Aigerim Abdurakhmanova on 27.06.2022.
//

import UIKit
import MapKit

class TableViewCell: UITableViewCell {

//    var pin: MKPointAnnotation? {
//        didSet {
//            cityLabel.text = pin?.title
//            titleLabel.text = pin?.subtitle
//        }
//    }
    
    var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(cityLabel)
        cityLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        cityLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        cityLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        self.contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
    }

}
