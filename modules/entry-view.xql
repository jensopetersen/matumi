module namespace matumi="http://www.asia-europe.uni-heidelberg.de/xquery/matumi";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace dict="http://exist-db.org/xquery/dict" at "dict2html.xql";
import module namespace search="http://exist-db.org/xquery/search" at "search.xql";
import module namespace browse="http://exist-db.org/xquery/apps/matumi/browse" at "browse.xqm";
import module namespace browse-books="http://exist-db.org/xquery/apps/matumi/browse-books" at "browse_books.xqm";
import module namespace metadata="http://exist-db.org/xquery/apps/matumi/metadata" at "metadata.xqm";


declare function matumi:entry($node as node()*, $params as element(parameters)?, $model as item()*) {
    let $doc := request:get-parameter("doc", ())
    let $id := request:get-parameter("id", ())
    return
        if ($id) then
            let $entry := doc($doc)//tei:div[@type = "entry"][@subtype = $id]
            return
                templates:process($node/node(), $entry)
        else
            let $nodeId := request:get-parameter("node", ())
            let $target := util:node-by-id(doc($doc), $nodeId)
            let $entry := $target/ancestor-or-self::tei:div[@type = "entry"]
            return
                templates:process($node/node(), $entry)
};

declare function matumi:encyclopedia-title($node as node()*, $params as element(parameters)?, $model as item()*) {
   let $title0 := $model/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt/tei:title/text(),
       $title := if( $title0 = ('', 'title', 'Title')) then 
                    concat('[',  util:document-name($title0), ']') 
                 else $title0
    return <a href="metadata.html?doc={  document-uri( root($model)) }">{ $title }</a>
};

declare function matumi:encyclopedia-subjects($node as node()*, $params as element(parameters)?, $model as item()*) {
    <a href="browse.html?L1=subjects&amp;L2=entries&amp;L3=names&amp;L4=books&amp;subject={$model/@subtype/string()}">{ $model/@subtype/string() }</a>
   
};

declare function matumi:format-entry($node as node()*, $params as element(parameters)?, $model as item()*) {
    dict:entry($model)
};

declare function matumi:tabs($node as node()*, $params as element(parameters)?, $model as item()*) {
    let $uri := replace(request:get-uri(), "^.*/([^/]+)$", "$1")
    let $log := util:log("DEBUG", ("$uri = ", $uri))
    return
        <ul class="tabs">{ for $child in $node/node() return matumi:process-tabs($child, $uri) }</ul>
};

declare function matumi:process-tabs($node as node(), $active as xs:string) {
    typeswitch ($node)
        case element(a) return
            <a>
            { 
                $node/@href,
                if ($node/@href eq $active) then
                    attribute class { "active" }
                else
                    (),
                $node/node()
            }
            </a>
        case element() return
            element { node-name($node) } {
                $node/@*, for $child in $node/node() return matumi:process-tabs($child, $active)
            }
        default return
            $node
};

declare function matumi:search($node as node()*, $params as element(parameters)?, $model as item()*) {
    let $results := search:search()
    return
        templates:process($node/node(), $results)
};

declare function matumi:results($node as node()*, $params as element(parameters)?, $model as item()*) {
    search:show-results($model)
};

declare function matumi:facets($node as node()*, $params as element(parameters)?, $model as item()*) {
    let $view := $params/param[@name = "view"]/@value/string()
    return
        <div class="facet-list">
        { search:show-facets($model, $view) }
        </div>
};

declare function matumi:query-form($node as node()*, $params as element(parameters)?, $model as item()*) {
    search:query-form()
};

declare function matumi:browse-boxes($node as node()*, $params as element(parameters)?, $model as item()*) {
    browse:level-boxes()
};

declare function matumi:browse-grid($node as node()*, $params as element(parameters)?, $model as item()*) {
     <div class="grid_16 browse-grid"> 
        { browse:page-grid( false() ) }
     </div>
};

declare function matumi:metadata-combo($node as node()*, $params as element(parameters)?, $model as item()*) {
   metadata:all( $node, $params, $model) 
};

