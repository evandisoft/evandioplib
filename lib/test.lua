local lib={}

local function shallowcopy(t)
    local t2={}
    for k,v in pairs(t) do
        t2[k]=v
    end
    return setmetatable(t2,getmetatable(t))
end

local actionlistMetatable={
    __index={
        classname="actionlist",
        name="",
        n=1
    },
    __mul=function(t,n)
        if(type(n)~="number") then
            print("can't multiply actionlist by a non-number")
            return t
        end
        local t2=shallowcopy(t)
        t2.n=t2.n*n
        return t2
    end
}

lib.actionlist=function(...)
    return setmetatable({actions={...}},actionlistMetatable)
end

local actionMetatable={
    __index={
        classname="action",
        n=1
    },
    __call=function(t,...)
        local t2=shallowcopy(t)
        t2.args={...}
        return t2
    end,
    __mul=function(t,n)
        if(type(n)~="number") then
            print("can't multiply action by a non-number")
            return t
        end
        local t2=shallowcopy(t)
        t2.n=t2.n*n
        return t2
    end
}

local robot=require("robot")
-- turns lib.robot.X(A,B,C)*N into {classname="action",name=X,f=robot.X,args={A,B,C},n=N}
lib.robot=setmetatable({},{
    __index=function(t,key)
        local obj={
            name=key,
            f=robot[key],
            args={}
        }
        return setmetatable(obj,actionMetatable)
    end
})

return lib