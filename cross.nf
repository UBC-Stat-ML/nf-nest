def auto_name(config) {
    config.collect{key, value -> "$key=$value"}.join("___") + ".csv"
}

def crossProduct(Map<String, List<?>> mapOfLists, boolean dryRun) {
    if (dryRun) {
        def result = [:]
        for (key in mapOfLists.keySet()) {
            check(key, result[key])
            def list = mapOfLists[key]
            result[key] = list.first()
        }
        return Channel.of(result)
    } else 
        crossProduct(mapOfLists)
}

def crossProduct(Map<String, List<?>> mapOfLists) {
    def keys = new ArrayList(mapOfLists.keySet())
    def list = _crossProduct(mapOfLists, keys)
    return Channel.fromList(list)
}

def _crossProduct(mapOfLists, keys) {
    if (keys.isEmpty()) {
        return [[:]]
    }
    def key = keys.remove(keys.size() - 1)
    def result = []
    for (recursiveMap : _crossProduct(mapOfLists, keys))
        for (value : mapOfLists.get(key)) {
            check(key, value)
            def copy = new LinkedHashMap(recursiveMap)
            copy[key] = value 
            result.add(copy)
        }
    return result
}

def check(_key, _value) {
    def key = "" + _key 
    def value = "" + _value
    if (key.contains("___") || value.contains("___"))
        throw new Exception("Keys and values should not contain '___' but got: $key, $value")
    if (key.contains("="))
        throw new Exception("Keys should not contain '=' but got: $key")
}