//
//  FullPictureViewController.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/14/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit

class FullPictureViewController: UIViewController {
    
    var taskEntity: TaskEntity!
    var bucket: BucketList<TaskEntity>!
    var imageIndex: Int!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func trashButtonClicked(sender: AnyObject) {
        let controller = UIAlertController(title: "Delete Image From Task Gallery?",
            message: nil, preferredStyle: .ActionSheet)
        let yesAction = UIAlertAction(title: "Yes!",
            style: .Destructive, handler: { action in
                print("User chose to delete image")
                self.bucket.removeImageForEntityForIndex(self.taskEntity, index: self.imageIndex)
                self.navigationController!.popViewControllerAnimated(true)
        })
        let noAction = UIAlertAction(title: "Cancel",
            style: .Cancel, handler: nil)
        controller.addAction(yesAction)
        controller.addAction(noAction)
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = sender as? UIView
            ppc.sourceRect = sender.bounds
        }
        presentViewController(controller, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let image = bucket.getImageForEntityForIndex(self.taskEntity, index: self.imageIndex)
        if image == nil {
            print("Unexpectedly got a nil image for full view")
        } else {
            imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
