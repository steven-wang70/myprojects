//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Wang, Steven on 2018-11-22.
//  Copyright © 2018 Wang, Steven. All rights reserved.
//

import UIKit
import Foundation
import SAPCommon
import SAPFoundation
import SAPOData
import SAPOfflineOData

class BaseViewController:   UIViewController,
                            UIImagePickerControllerDelegate, // Interface for image picker
                            UINavigationControllerDelegate, // Interface for image picker
                            UITableViewDelegate, // Interface for Tableiew to display entity items
                            UITableViewDataSource { // Interface for Tableiew to display entity items
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        do {
            try prepareStore()
            try openStore()
        } catch {
            return
        }
    }

    public var provider: OfflineODataProvider? = nil
    public var service: AlbumService<OfflineODataProvider>? = nil
    private var photos: Array<Photos> = []

    @IBOutlet weak var tableView: UITableView!
    
    private func prepareStore() throws -> Void {
        let docFolder = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory,
                                                    FileManager.SearchPathDomainMask.userDomainMask,
                                                    true )[ 0 ]

        // In this sample application, we are using a local offline odata store without backend server.
        // That's why we included local store .udb files in the project, and at beginning, we need to
        // copy these store files to the right location if required.
        // This sample application does not show case how to connect to the server.
        let fm = FileManager.default
        if ( !fm.fileExists(atPath: docFolder + "/Album.udb") ) {
            let resourcePath: String = Bundle.main.resourcePath!
            try fm.copyItem( atPath: resourcePath + "/Album.udb", toPath: docFolder + "/Album.udb" )
            try fm.copyItem( atPath: resourcePath + "/Album.rq.udb", toPath: docFolder + "/Album.rq.udb" )
        }
    }

    private func openStore() throws -> Void {
        let localServiceRoot = URL( string: "http://localhost:8180/odata/Album/" )!
        var params: OfflineODataParameters = OfflineODataParameters()
        // Set offline odata parameters
        params.storeName = "Album"
        params.pageSize = OfflineODataParameters.noPaging

        provider = try OfflineODataProvider( serviceRoot: localServiceRoot, parameters: params, sapURLSession: SAPURLSession( configuration: URLSessionConfiguration.default, delegate: nil), delegate: nil )
        service = AlbumService( provider: provider! )

        service!.open { (error) in
                if (error == nil) {
                    self.populateTableView()
                } else {
                    self.alert("Open offline store failed.")
                }
            }
    }

    private func gotImageStream(_ imageStream: ByteStream, _ updatingPhotoEntity: Photos?) -> Void {
        // If the updatingPhotoEntity is not nil, we are updating an entity
        if (updatingPhotoEntity != nil) {
            updatingPhotoEntity!.title = "Updated at: \(dateString())"
            do {
                // Calling updateEntity() to update properties to local store. It does not update the image
                try service?.updateEntity(updatingPhotoEntity!)
                // Instead, you need to call uploadMedia() for an entity to update the image with a new one
                try service?.uploadMedia(entity: updatingPhotoEntity!, content: imageStream)
                getActiveRow()?.pictureLabel?.text = updatingPhotoEntity!.title
            } catch {
                alert("Update photo failed.")
            }
        } else { // Otherwise, it is creating a new one
            let newEntity = Photos()
            newEntity.title = "Added at: \(dateString())"
            do {
                // Calling createMedia() persist the new entity to local store with normal proeprties, and image
                // in the parameter "content".
                try service?.createMedia(entity: newEntity, content: imageStream)
                addPhotoToTableView(newEntity)
            } catch {
                alert("Add photo failed.")
            }
        }
    }

    private func dateString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM-dd HH:mm:ss"
        return dateFormatterPrint.string(from: Date())
    }

    private func closeStore() throws -> Void {
        if (provider != nil) {
            try provider!.close()
        }
    }

    private func populateTableView() -> Void {
        do {
            photos = try (service?.fetchPhotos())!
        } catch {
            alert("Populate the photo list failed.")
        }

        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(photos.count)
        for index in 0..<photos.count {
            indexPaths.append(IndexPath.init(row: index, section: 0))
        }
        DispatchQueue.main.async{
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }

    private func addPhotoToTableView(_ photoEntity: Photos) {
        photos.append(photoEntity)
        let indexPaths: [IndexPath] = [IndexPath.init(row: photos.count - 1, section: 0)]
        DispatchQueue.main.async{
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }

    private func getActiveRow() -> PhotoItemViewCell? {
        let indexPath = tableView.indexPathForSelectedRow
        if (indexPath != nil) {
            let cell = tableView.cellForRow(at: indexPath!) as! PhotoItemViewCell
            return cell
        } else {
            return nil
        }
    }

    internal func addFromLibrary() -> Void {
        getPhoto(nil, .photoLibrary)
    }

    internal func addFromCamera() -> Void {
        getPhoto(nil, .camera)
    }

    internal func updateFromLibrary() -> Void {
        updatePhoto(.photoLibrary)
    }

    internal func updateFromCamera() -> Void {
        updatePhoto(.camera)
    }

    private func updatePhoto(_ sourceType: UIImagePickerController.SourceType) -> Void {
        let row = getActiveRow()
        if (row == nil) {
            alert("Please select an item to update.")
            return
        }

        confirm("Are you sure to update the photo?") {
            self.getPhoto(row!.photoEntity, sourceType)
        }
    }

    internal func deletePhoto() -> Void {
        let row = getActiveRow()
        if (row == nil) {
            alert("Please select an item to delete.")
            return
        }

        confirm("Are you sure to delete the photo?") {
            do {
                // Deleting a media entity is just the same as deleting a normal entity.
                try self.service!.deleteEntity(row!.photoEntity!)
                let indexPath = self.tableView.indexPathForSelectedRow!
                self.photos.remove(at: indexPath.row)
                DispatchQueue.main.async{
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                    self.tableView.endUpdates()
                }
            } catch {
                self.alert("Delete photo failed.")
            }
        }

    }

    internal func displayPhoto(_ photoEntity: Photos) {
        do {
            let stream = try service?.downloadMedia(entity: photoEntity)
            defer {
                do {
                    try stream?.close()
                } catch {}
            }

            let readLength = 64*1024
            var image = Data()
            while true {
                let data = try stream?.readBinary(length: readLength)
                if (data == nil) {
                    break
                }

                if (data!.count > 0) {
                    image.append(data!)
                }

                if (data!.count < readLength) {
                    break
                }
            }

            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            viewController.setPhoto(image)
            self.present(viewController, animated: true, completion: nil)
        } catch {

        }
    }

    private func alert(_ msg: String) -> Void {
        let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertController.addAction(actionOK)
        self.present(alertController, animated: true, completion: nil)
    }

    private func confirm(_ msg: String, completion: @escaping () -> Void) -> Void {
        let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)

        let actionOK = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            completion()
        }
        alertController.addAction(actionOK)

        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        alertController.addAction(actionCancel)

        self.present(alertController, animated: true, completion: nil)
    }

    private var targetPhotoEntity: Photos? = nil
    private func getPhoto(_ updatingPhotoEntity: Photos?, _ sourceType: UIImagePickerController.SourceType) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) { // Before opening image picker, first check whether it is available or not.
            let imagePicker = UIImagePickerController()
            targetPhotoEntity = updatingPhotoEntity
            imagePicker.delegate = self // Set the delegate interface
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    // You must set the calling onvention @objc here. Otherwise the application will crash while returning from image picker.
    // Without the @objc, it will cause error: [discovery] errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}
    // See: https://stackoverflow.com/questions/44465904/photopicker-discovery-error-error-domain-pluginkit-code-13

    // You could test photo library with simulator.
    // To test camera, you must use a real device instead of simulator, and set the correct privacy of the camera in the file info.plist.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : AnyObject]) {
        defer {
            dismiss(animated:true, completion: nil)
        }

        if (picker.sourceType == .camera) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage // iOS manages images in UIImage.
            let compressedImage = image.jpegData(compressionQuality: 0.3) // Compress the image to jpeg format with ratio 0.3
            let imageStream = ByteStream.fromBinary(data: compressedImage!) // Construct an SAPOData ByteStream from the jpeg data.
            imageStream.mediaType = "images/jpeg" // Set the stream mediaType
            gotImageStream(imageStream, targetPhotoEntity)
            targetPhotoEntity = nil
        } else if (picker.sourceType == .photoLibrary) {
            let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as! URL
            defer {
                targetPhotoEntity = nil
            }

            do {
                let filePath = imageUrl.absoluteURL.path
                let imageStream = try ByteStream.fromFile(filePath) // Construct an SAPOData ByteStream from file.
                imageStream.mediaType = "image/" + (filePath as NSString).pathExtension // Set the correct stream mediaType.
                gotImageStream(imageStream, targetPhotoEntity)
            } catch {
                alert("Pick photo from library failed.")
            }
        }
    }

    // Interfaces for TableView operations.
    let cellReuseIdentifier = "PhotoItemViewCell"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PhotoItemViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PhotoItemViewCell

        cell.setPhoto(photos[indexPath.row], self)
        return cell
    }
}

