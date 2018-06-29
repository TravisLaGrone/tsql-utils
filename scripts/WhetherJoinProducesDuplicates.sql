/* Pseudocode:

FOREACH join:
    IF join/ed/ (i.e. the new table) set of columns (filtered by constants, if any) is unique statically THEN
        the join does not increase the rowset cardinality -> does not cause duplicates
    ELSE IF join/ed/ (i.e. the new table) set of columns (filtered by constants, if any) is unique empirically THEN
        the join /probably/ does not increase the rowset cardinality -> probably does not cause duplicates
    ELSE IF join/ed/ (i.e. the new table) set of columns (filtered by constants, if any) union selected columns is unique statically THEN
        the join does not increase the rowset cardinality -> does not cause duplicates
    ELSE IF join/ed/ (i.e. the new table) set of columns (filtered by constants, if any) union selected columns is unique empirically THEN
        the join /probably/ does not increase the rowset cardinality -> probably does not cause duplicates
    ELSE IF join has descendent join(s) and the cumulative effect of them is to filter this join such that all columns (joined and selected) are [statically | empirically] unique THEN
        the join [probably] does not increase the rowset cardinality -> probably does not cause duplicates

TODO:  determine "object reference" DAG (graph) amongst FROM and JOINs in CV query
* direct parents of join
    * ancestors of join
* direct children of join
    * descendant of join

*/