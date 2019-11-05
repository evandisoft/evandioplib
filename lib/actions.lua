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
        name="_",
        n=1
    },
    __mul=function(t,object)
        if type(object)=="number" then
            local t2=shallowcopy(t)
            t2.n=t2.n*object
            return t2
        elseif type(object)=="string" then
            local t2=shallowcopy(t)
            t2.name=object
            return t2
        else
            print("mul on actionlist only works with number or string")
            return t
        end
    end
}

lib.actionlist=function(arg1,...)
    local actions={...} or {}
    local list={}
    if type(arg1) == "table" then
        table.insert(actions,1,arg1)
    elseif type(arg1) == "string" then
        list.name=arg1
    else
        print("first arg must be string or table")
    end
    list.actions=actions

    return setmetatable(list,actionlistMetatable)
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
        if type(n)=="number" then
            local t2=shallowcopy(t)
            t2.n=t2.n*n
            return t2
        else
            print("mul on actions only works with numbers")
            return t
        end
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

lib.run=function(object,prevnames)
    local suffix=""
    if type(object)=="table" then
        if prevnames then
            prevnames=prevnames..","..object.name
        else
            prevnames=object.name
        end

        if object.classname=="actionlist" then
            for i=1,object.n do
                -- if object.n~=1 then
                --     suffix=i
                -- end
                suffix=i
                for k,v in pairs(object.actions) do
                    lib.run(v,prevnames..suffix)
                end
            end
        elseif object.classname=="action" then
            for i=1,object.n do
                -- if object.n~=1 then
                --     suffix=i
                -- end
                suffix=i
                print("Executing "..prevnames..suffix)
                object.f(table.unpack(object.args))
                os.sleep(0)
            end
        else
            print("class was not 'actionlist' or 'action'")
        end
    else
        print("object "..object.." was not a table")
    end
end

return lib