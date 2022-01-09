//
//  ConversationTableViewCell.swift
//  ChatEver
//
//  Created by administrator on 09/01/2022.
//

import UIKit
import SDWebImage

class CustomCellFriend: UITableViewCell {
    
    // MARK: - Variables
    static let identifier = "cellFriend"
    
    // MARK: - UI Elements
    private let friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let friendNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()

    private let friendMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(friendImageView)
        contentView.addSubview(friendNameLabel)
        contentView.addSubview(friendMessageLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        friendImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)

        friendNameLabel.frame = CGRect(x: friendImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - friendImageView.width,
                                     height: (contentView.height-20)/2)

        friendMessageLabel.frame = CGRect(x: friendImageView.right + 10,
                                        y: friendNameLabel.bottom + 10,
                                        width: contentView.width - 20 - friendImageView.width,
                                        height: (contentView.height-20)/2)

    }

    public func configure(with model: Conversation) {
        friendMessageLabel.text = model.latestMessage.text
        friendNameLabel.text = model.name

        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadImageURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):

                DispatchQueue.main.async {
                    self?.friendImageView.sd_setImage(with: url, completed: nil)
                }

            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }

}
