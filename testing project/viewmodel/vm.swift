//
//  vm.swift
//  testing project
//
//  Created by Theappmedia on 5/12/22.
//

import Foundation
import UIKit

class FileManagerClass {
    static let instance = FileManagerClass()
     
    func getPath(name:String ,image : UIImage){
        let data = image.jpegData(compressionQuality: 1.0)
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).jpg")
        do{
            
            try data?.write(to: directory!)
        }catch{
            
        }
        print(directory)
    }
}
class ViewModel:ObservableObject {
    @Published var newImage :UIImage?
    let manager = FileManagerClass.instance
    init(){
        getImageFromAssests()
    }
    let image: String = "1"
    @Published var uiImage: UIImage? = nil
    func getImageFromAssests(){
        uiImage = UIImage(named: image)
    }
    func getimageFromfilemNager(name:String)->UIImage{
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).jpg").path
        let data = FileManager.default.fileExists(atPath: directory!)
        return UIImage(contentsOfFile: directory!)!
        
    }
    func nn(){
        self.newImage = getimageFromfilemNager(name: image)
    }
}

