//# xsc 18.12.0-SNAPSHOT-acea4a-20181122
// The command to generate this proxy file is:
// ./xs-proxy.sh album_metadata.xml album_metadata.xml.xs -pretty -service generic:AlbumService
// ./xsc.sh album_metadata.xml.xs -swift -ds.generic -swift:import SAPOData -d .

import SAPOData
import Foundation

open class AlbumService<Provider: DataServiceProvider>: DataService<Provider> {
    public override init(provider: Provider) {
        super.init(provider: provider)
        self.provider.metadata = AlbumServiceMetadata.document
    }

    open func fetchPhotos(matching query: DataQuery? = nil, headers: HTTPHeaders? = nil, options: RequestOptions? = nil) throws -> Array<Photos> {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:200:5
        let var_query: DataQuery = DataQuery.newIfNull(query: query)
        let var_headers: HTTPHeaders = HTTPHeaders.emptyIfNull(headers: headers)
        let var_options: RequestOptions = try RequestOptions.noneIfNull(options: options)
        return try Photos.array(from: self.executeQuery(var_query.fromDefault(AlbumServiceMetadata.EntitySets.photos), headers: var_headers, options: var_options).entityList())
    }

    open func fetchPhotos(matching query: DataQuery = DataQuery(), headers: HTTPHeaders? = nil, options: RequestOptions? = nil, completionHandler: @escaping (Array<Photos>?, Error?) -> Void) -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:251:5
        self.addBackgroundOperationForFunction {
        do {
            let result: Array<Photos> = try self.fetchPhotos(matching: query, headers: headers, options: options)
            self.completionQueue.addOperation {
                completionHandler(result, nil)
            }
        }
        catch let error {
            self.completionQueue.addOperation {
                completionHandler(nil, error)
            }
        }
        }
    }

    open func fetchPhotos1(matching query: DataQuery, headers: HTTPHeaders? = nil, options: RequestOptions? = nil) throws -> Photos {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:192:5
        let var_headers: HTTPHeaders = HTTPHeaders.emptyIfNull(headers: headers)
        let var_options: RequestOptions = try RequestOptions.noneIfNull(options: options)
        return try CastRequired<Photos>.from(self.executeQuery(query.fromDefault(AlbumServiceMetadata.EntitySets.photos), headers: var_headers, options: var_options).requiredEntity())
    }

    open func fetchPhotos1(matching query: DataQuery, headers: HTTPHeaders? = nil, options: RequestOptions? = nil, completionHandler: @escaping (Photos?, Error?) -> Void) -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:221:5
        self.addBackgroundOperationForFunction {
        do {
            let result: Photos = try self.fetchPhotos1(matching: query, headers: headers, options: options)
            self.completionQueue.addOperation {
                completionHandler(result, nil)
            }
        }
        catch let error {
            self.completionQueue.addOperation {
                completionHandler(nil, error)
            }
        }
        }
    }

    @available(swift, deprecated: 4.0, renamed: "fetchPhotos")
    open func photos(query: DataQuery = DataQuery()) throws -> Array<Photos> {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:210:5
        return try self.fetchPhotos(matching: query)
    }

    @available(swift, deprecated: 4.0, renamed: "fetchPhotos")
    open func photos(query: DataQuery = DataQuery(), completionHandler: @escaping (Array<Photos>?, Error?) -> Void) -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:281:5
        self.fetchPhotos(matching: query, headers: nil, options: nil, completionHandler: completionHandler)
    }

    override open func refreshMetadata() throws -> Void {
        objc_sync_enter(self)
        defer { objc_sync_exit(self); }
        do {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:183:19
            try ProxyInternal.refreshMetadata(service: self, fetcher: nil, options: AlbumServiceMetadataParser.options)
            AlbumServiceMetadataChanges.merge(metadata: self.metadata)
        }
    }

    //# throwing functions for class AlbumService: fetchPhotos, fetchPhotos1, photos, refreshMetadata
}

internal class AlbumServiceFactory {
    static func registerAll() throws -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:129:12
        AlbumServiceMetadata.EntityTypes.photos.registerFactory(ObjectFactory.with(create: { Photos(withDefaults: false) }, createWithDecoder: { d in try Photos(from: d) } ))
        AlbumServiceStaticResolver.resolve()
    }

    //# throwing functions for class AlbumServiceFactory: registerAll
}

public class AlbumServiceMetadata {
    private static var document_: CSDLDocument = AlbumServiceMetadata.resolve()

    public static var document: CSDLDocument {
        get {
            objc_sync_enter(AlbumServiceMetadata.self)
            defer { objc_sync_exit(AlbumServiceMetadata.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:105:36
                return AlbumServiceMetadata.document_
            }
        }
        set(value) {
            objc_sync_enter(AlbumServiceMetadata.self)
            defer { objc_sync_exit(AlbumServiceMetadata.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:105:36
                AlbumServiceMetadata.document_ = value
            }
        }
    }

    private static func resolve() -> CSDLDocument {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:119:12
        try! AlbumServiceFactory.registerAll()
        AlbumServiceMetadataParser.parsed.hasGeneratedProxies = true
        return AlbumServiceMetadataParser.parsed
    }

    public class EntityTypes {
        private static var photos_: EntityType = AlbumServiceMetadataParser.parsed.entityType(withName: "SAPSQLOData.Photos")

        public static var photos: EntityType {
            get {
                objc_sync_enter(AlbumServiceMetadata.EntityTypes.self)
                defer { objc_sync_exit(AlbumServiceMetadata.EntityTypes.self); }
                do {
                    //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:109:40
                    return AlbumServiceMetadata.EntityTypes.photos_
                }
            }
        set(value) {
            objc_sync_enter(AlbumServiceMetadata.EntityTypes.self)
            defer { objc_sync_exit(AlbumServiceMetadata.EntityTypes.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:109:40
                AlbumServiceMetadata.EntityTypes.photos_ = value
            }
        }
        }
    }

    public class EntitySets {
        private static var photos_: EntitySet = AlbumServiceMetadataParser.parsed.entitySet(withName: "Photos")

        public static var photos: EntitySet {
            get {
                objc_sync_enter(AlbumServiceMetadata.EntitySets.self)
                defer { objc_sync_exit(AlbumServiceMetadata.EntitySets.self); }
                do {
                    //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:114:40
                    return AlbumServiceMetadata.EntitySets.photos_
                }
            }
        set(value) {
            objc_sync_enter(AlbumServiceMetadata.EntitySets.self)
            defer { objc_sync_exit(AlbumServiceMetadata.EntitySets.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:114:40
                AlbumServiceMetadata.EntitySets.photos_ = value
            }
        }
        }
    }
}

internal class AlbumServiceMetadataChanges {
    static func merge(metadata: CSDLDocument) -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:316:20
        metadata.hasGeneratedProxies = true
        AlbumServiceMetadata.document = metadata
        AlbumServiceMetadataChanges.merge1(metadata: metadata)
        try! AlbumServiceFactory.registerAll()
    }

    private static func merge1(metadata: CSDLDocument) -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:307:21
        Ignore.valueOf_any(metadata)
        if !AlbumServiceMetadata.EntityTypes.photos.isRemoved {
            AlbumServiceMetadata.EntityTypes.photos = metadata.entityType(withName: "SAPSQLOData.Photos")
        }
        if !AlbumServiceMetadata.EntitySets.photos.isRemoved {
            AlbumServiceMetadata.EntitySets.photos = metadata.entitySet(withName: "Photos")
        }
        if !Photos.pk.isRemoved {
            Photos.pk = AlbumServiceMetadata.EntityTypes.photos.property(withName: "pk")
        }
        if !Photos.title.isRemoved {
            Photos.title = AlbumServiceMetadata.EntityTypes.photos.property(withName: "title")
        }
    }
}

internal class AlbumServiceMetadataParser {
    internal static let options: Int = (CSDLOption.allowCaseConflicts | CSDLOption.disableFacetWarnings | CSDLOption.disableNameValidation | CSDLOption.processMixedVersions | CSDLOption.retainOriginalText | CSDLOption.ignoreUndefinedTerms)

    internal static let parsed: CSDLDocument = AlbumServiceMetadataParser.parse()

    static func parse() -> CSDLDocument {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:91:12
        let parser: CSDLParser = CSDLParser()
        parser.logWarnings = false
        parser.csdlOptions = AlbumServiceMetadataParser.options
        let metadata: CSDLDocument = parser.parseInProxy(AlbumServiceMetadataText.xml, url: "SAPSQLOData")
        metadata.proxyVersion = "18.12.0-SNAPSHOT-acea4a-20181122"
        return metadata
    }
}

internal class AlbumServiceMetadataText {
    internal static let xml: String = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\" ?>\n<edmx:Edmx xmlns:edmx=\"http://schemas.microsoft.com/ado/2007/06/edmx\" Version=\"1.0\">\n<edmx:DataServices xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" m:DataServiceVersion=\"1.0\">\n<Schema xmlns=\"http://schemas.microsoft.com/ado/2008/09/edm\" Namespace=\"SAPSQLOData\" xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\">\n<EntityType Name=\"Photos\" m:HasStream=\"true\">\n<Key>\n<PropertyRef Name=\"pk\"/>\n</Key>\n<Property Name=\"pk\" Nullable=\"false\" Type=\"Edm.Int32\"/>\n<Property Collation=\"UTF8BIN\" MaxLength=\"20\" Name=\"title\" Nullable=\"false\" Type=\"Edm.String\"/>\n</EntityType>\n<EntityContainer Name=\"SAPSQLOData_Container\" m:IsDefaultEntityContainer=\"true\">\n<EntitySet EntityType=\"SAPSQLOData.Photos\" Name=\"Photos\"/>\n</EntityContainer>\n</Schema>\n</edmx:DataServices>\n</edmx:Edmx>\n"
}

internal class AlbumServiceStaticResolver {
    static func resolve() -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:336:20
        AlbumServiceStaticResolver.resolve1()
    }

    private static func resolve1() -> Void {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:328:21
        Ignore.valueOf_any(AlbumServiceMetadata.EntityTypes.photos)
        Ignore.valueOf_any(AlbumServiceMetadata.EntitySets.photos)
        Ignore.valueOf_any(Photos.pk)
        Ignore.valueOf_any(Photos.title)
    }
}

open class Photos: EntityValue {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    private static var pk_: Property = AlbumServiceMetadata.EntityTypes.photos.property(withName: "pk")

    private static var title_: Property = AlbumServiceMetadata.EntityTypes.photos.property(withName: "title")

    public init(withDefaults: Bool = true) {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:36:5
        super.init(withDefaults: withDefaults, type: AlbumServiceMetadata.EntityTypes.photos)
    }

    open class func array(from: EntityValueList) -> Array<Photos> {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:31:12
        return ArrayConverter.convert(from.toArray(), Array<Photos>())
    }

    open func copy() -> Photos {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:20:5
        return CastRequired<Photos>.from(self.copyEntity())
    }

    override open var isProxy: Bool {
        get {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:8:5
            return true
        }
    }

    open class func key(pk: Int) -> EntityKey {
        //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:25:12
        return EntityKey().with(name: "pk", value: IntValue.of(pk))
    }

    open var old: Photos {
        get {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:15:5
            return CastRequired<Photos>.from(self.oldEntity)
        }
    }

    open class var pk: Property {
        get {
            objc_sync_enter(Photos.self)
            defer { objc_sync_exit(Photos.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:47:36
                return Photos.pk_
            }
        }
        set(value) {
            objc_sync_enter(Photos.self)
            defer { objc_sync_exit(Photos.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:47:36
                Photos.pk_ = value
            }
        }
    }

    open var pk: Int {
        get {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:53:5
            return IntValue.unwrap(self.dataValue(for: Photos.pk))
        }
        set(value) {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:58:5
            self.setDataValue(for: Photos.pk, to: IntValue.of(value))
        }
    }

    open class var title: Property {
        get {
            objc_sync_enter(Photos.self)
            defer { objc_sync_exit(Photos.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:48:36
                return Photos.title_
            }
        }
        set(value) {
            objc_sync_enter(Photos.self)
            defer { objc_sync_exit(Photos.self); }
            do {
                //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:48:36
                Photos.title_ = value
            }
        }
    }

    open var title: String {
        get {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:66:5
            return StringValue.unwrap(self.dataValue(for: Photos.title))
        }
        set(value) {
            //# /Users/i826582/Work/gitsrc/master101/import/content/SAPTools/bin/album_metadata.xml.xs:71:5
            self.setDataValue(for: Photos.title, to: StringValue.of(value))
        }
    }
}
