xquery version "1.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

declare variable $home external;
declare variable $dir external;

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

util:log("INFO", ("Running pre-install script ...")),
if (xdb:group-exists("biblio.users")) then ()
else xdb:create-group("biblio.users"),
if (xdb:exists-user("editor")) then ()
else xdb:create-user("editor", "editor", "biblio.users", ()),

util:log("INFO", ("Loading collection configuration ...")),
local:mkcol("/db/system/config", "db/encyclopedia"),
xdb:store-files-from-pattern("/system/config/db/encyclopedia", $dir, "*.xconf")