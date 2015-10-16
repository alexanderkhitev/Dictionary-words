//
//  DictionaryTableViewController.swift
//  Dictionary words
//
//  Created by Alexsander  on 10/13/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class DictionaryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    // MARK: - var and let
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Alamofire
    let alamofire = AlamofireVersionNumber
    var fetchedResultsController: NSFetchedResultsController!
    // Search controller
    var searchController: UISearchController!
    var searchPredicate: NSPredicate!
    var searchArray = [AnyObject]()
    
    var internetArray = [String]()
    var boolInternetSearch = false
    // for save
    var saveOriginalText: String!
    var saveTranslatedText: String!
    // Activity controller
    var activityView = UIActivityIndicatorView()
    
    // MARK: - IBOutet
    @IBOutlet weak var navigationItemGeneral: UINavigationItem! 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.definesPresentationContext = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    
        activityView.hidesWhenStopped = true
        activityView.color = UIColor.whiteColor()
        navigationItemGeneral.titleView = activityView
    
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "wordOriginal", cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("fetched results controller error")
        }
        
        searchController = ({
            let controllerSearch = UISearchController(searchResultsController: nil)
            controllerSearch.delegate = self
            controllerSearch.searchBar.delegate = self
            controllerSearch.searchResultsUpdater = self
            controllerSearch.dimsBackgroundDuringPresentation = false
            controllerSearch.hidesNavigationBarDuringPresentation = false
            controllerSearch.searchBar.sizeToFit()
            tableView.tableHeaderView = controllerSearch.searchBar
            return controllerSearch
        })()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return fetchedResultsController.sections?.count ?? 0
        } else {
            if boolInternetSearch == false {
                print("searchArray")
                return 1 ?? 0
            } else {
                return 1 ?? 0
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            if boolInternetSearch == false {
                return searchArray.count ?? 0
            } else {
                return internetArray.count ?? 0
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WordTableViewCell
        if searchPredicate == nil {
            let data = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
            cell.originalWord.text = data.wordOriginal
            cell.translatedWord.text = data.wordTranslation
        } else {
            if boolInternetSearch == false {
            let searchData = searchArray[indexPath.row] as! Word
            
            cell.originalWord.text = searchData.wordOriginal
            cell.translatedWord.text = searchData.wordTranslation!
            } else {
                let translatedData = internetArray[indexPath.row]
                cell.originalWord.text = saveOriginalText
                cell.translatedWord.text = translatedData
//                boolInternetSearch = false
            }
        }
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Update:
            tableView.cellForRowAtIndexPath(indexPath!)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Move:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Update:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    // MARK: - edit table and insert
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            managedObjectContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try managedObjectContext.save()
            } catch {
                print("error managed object context in dictionary table")
            }
        } else if editingStyle == .Insert {
            
        }    
    }
    
    // MARK: - Functions
    
    func fetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let sortDescriptor = NSSortDescriptor(key: "wordOriginal", ascending: true)
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 100
        return fetchRequest
    }
    
    // MARK: search results controller functions
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if searchText != nil {
            activityView.startAnimating()
            searchPredicate = NSPredicate(format: "wordOriginal contains[c] %@", searchText!)
            searchArray = fetchedResultsController.fetchedObjects?.filter() {
                return searchPredicate.evaluateWithObject($0)
            } as [AnyObject]!
            tableView.reloadData()

        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        internetArray.removeAll(keepCapacity: false)
        boolInternetSearch = true
        saveOriginalText = searchController.searchBar.text!
        var langpair: String!
        //
        let keyboardLanguage = searchController.searchBar.textInputMode!.primaryLanguage!
        let arrayLanguage = keyboardLanguage.componentsSeparatedByString("-")
        let primaryLanguage = arrayLanguage[0]
        print(primaryLanguage)
        //
        if primaryLanguage == "en" {
            langpair = "\(primaryLanguage)|ru"
        } else {
            langpair = "\(primaryLanguage)|en"
        }
        
        let requestString = "http://api.mymemory.translated.net/get?q=\(saveOriginalText)!&langpair=\(langpair)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        print(requestString)
        Alamofire.request(.GET, requestString).responseJSON(options: NSJSONReadingOptions.AllowFragments, completionHandler: { (response) -> Void in
            print(response.result)
            let mainDictionary = response.result.value! as! [String : AnyObject]
            let responseData = mainDictionary["responseData"] as! [String: AnyObject]
            let translatedText = responseData["translatedText"] as! String
            print(translatedText)
            self.saveTranslatedText = translatedText
            self.internetArray.append(translatedText)
            self.tableView.reloadData()
            
            let entityWord = NSEntityDescription.insertNewObjectForEntityForName("Word", inManagedObjectContext: self.managedObjectContext) as! Word
            entityWord.wordDate = NSDate()
            entityWord.wordOriginal = self.saveOriginalText
            entityWord.wordTranslation = self.saveTranslatedText
            do {
                try self.managedObjectContext.save()
                self.activityView.stopAnimating()
            } catch {
                print("There is an error when search buttom clicked")
            }

            })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
       boolInternetSearch = false
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        print("didDismissSearchController")
        activityView.stopAnimating()
        searchPredicate = nil
        internetArray.removeAll(keepCapacity: false)
        searchArray.removeAll(keepCapacity: false)
        tableView.reloadData()
    }

    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        print(indexPath)
            performSegueWithIdentifier("showResults", sender: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showResults" {
            activityView.stopAnimating()
            let showVC = segue.destinationViewController as! ShowResultViewController
            let indexPath = tableView.indexPathForSelectedRow!
            if searchPredicate == nil {
                let object = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
//            print(object)
                showVC.receiveOrigiganal = object.wordOriginal
                showVC.receiveTranslate = object.wordTranslation
            } else /* if search controller is not nil */ {
                if boolInternetSearch == false {
                let object = searchArray[indexPath.row] as! Word
                    showVC.receiveOrigiganal = object.wordOriginal
                    showVC.receiveTranslate = object.wordTranslation
                } else {
                    showVC.receiveOrigiganal = saveOriginalText
                    showVC.receiveTranslate = saveTranslatedText
                }
            }
        }
    }

}
