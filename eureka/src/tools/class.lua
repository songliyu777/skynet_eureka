-- Dmenu = class() -- 类名
-- Dmenu.__singleton = 名字 -- 开启单例模式

function _init_interface(class)
    if not class.getInstance then
        class.getInstance = function ( self )
            if class.__singleton then
                return _G[class.__singleton]
            end
            return _G[class]
        end
    end

    if not class.destroyInstance then
        class.destroyInstance = function ( self )
            if class.__singleton then
                return _G[class.__singleton]
            end
            return _G[class]
        end
    end
end

-- Instantiates a class
function _instantiate(class, ...)
    -- 抽象类不能实例化
    if rawget(class, "__abstract") then
        error("asbtract class cannot be instantiated.")
    end

    -- 单例模式，如果实例已经生成，则直接返回
    local singleton_name = rawget(class, "__singleton")
    if singleton_name then
        -- _G[class]值为本class的实例
        if _G[singleton_name] then
            _init_interface(_G[singleton_name])
            return _G[singleton_name]
        end
    end

    local inst = setmetatable({__class=class}, {__index = class})
    if inst.__init__ then
        inst:__init__(...)
    end

    --单例模式，如果实例未生成，则将实例记录到类中
    if singleton_name then
        if not _G[singleton_name] then
            _G[singleton_name] = inst
            _init_interface(_G[singleton_name])
        end
    end
    return inst
end

-- LUA类构造函数
function class(base)
    local metatable = {
        __call = _instantiate,
        __index = base
    }
    -- __parent 属性缓存父类，便于子类索引父类方法
    local _class = {__parent = base}

    -- 在class对象中记录 metatable ，以便重载 metatable.__index
    _class.__metatable = metatable

    return setmetatable(_class, metatable)
end

--- Test whether the given object is an instance of the given class.
-- @param object Object instance
-- @param class Class object to test against
-- @return Boolean indicating whether the object is an instance
-- @see class
-- @see clone
function instanceof(object, class)
    local meta = getmetatable(object)
    while meta and meta.__index do
        if meta.__index == class then
            return true
        end
        meta = getmetatable(meta.__index)
    end

    return false
end

