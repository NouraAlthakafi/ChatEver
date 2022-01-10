//
//  CustomCellFriend.swift
//  ChatEver
//
//  Created by administrator on 10/01/2022.
//

import UIKit
import SDWebImage

class CustomCellFriend: UITableViewCell {
    
    // MARK: - Variables
    static let identifier = "CustomCellFriend"
    
    // MARK: - UI Elements
    private let ivFriend: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let lbFriendName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let lbMessage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(ivFriend)
        contentView.addSubview(lbFriendName)
        contentView.addSubview(lbMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    override func layoutSubviews() {
        super.layoutSubviews()
        
        ivFriend.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        
        lbFriendName.frame = CGRect(x: ivFriend.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - ivFriend.width,
                                     height: (contentView.height-20)/2)
        
        lbMessage.frame = CGRect(x: ivFriend.right + 10,
                                        y: lbFriendName.bottom + 10,
                                        width: contentView.width - 20 - ivFriend.width,
                                        height: (contentView.height-20)/2)
        
    }
    
    public func configure(with model: Conversation) {
        lbMessage.text = model.latestMessage.text
        lbFriendName.text = model.name
        
        let path = "image/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadImageURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.ivFriend.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
    
}
