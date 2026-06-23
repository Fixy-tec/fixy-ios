//
//  HomeModels.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import Foundation

struct HomeUserDTO: Decodable {
    let full_name: String?
    let technologies: [String]?
}
