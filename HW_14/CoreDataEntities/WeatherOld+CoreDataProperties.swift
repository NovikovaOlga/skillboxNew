
import Foundation
import CoreData

extension WeatherOld {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherOld> {
        return NSFetchRequest<WeatherOld>(entityName: "WeatherOld")
    }

    @NSManaged public var dateOld: String?
    @NSManaged public var tempOld: String?
    @NSManaged public var feelsTempOld: String?

}
