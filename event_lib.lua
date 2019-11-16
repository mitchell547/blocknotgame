
function EventManager()
    local self = {}
    
    local events = {}
    local event_pool = {}
    
    function self.CatchEvent(event_name, callback0, subscriber0)
        if events[event_name] == nil then
            events[event_name] = {}
        end
        table.insert(events[event_name], {callback=callback0, subscriber=subscriber0})
    end
    
    function self.FireEvent(event_name, sender0, args0)
        if events[event_name] == nil then
            events[event_name] = {}
        end
        table.insert(event_pool, {name=event_name, sender=sender0, args=args0})
    end
    
    function self.Update()
        for i, event in pairs(event_pool) do
            for j, sub in pairs(events[event.name]) do
                if sub.subscriber then
                    sub.callback(sub.subscriber, event.args, event.sender)
                else
                    sub.callback(event.args, event.sender)
                end
            end            
        end
        for i, event in pairs(event_pool) do event_pool[i] = nil end
        event_pool = {}
    end
    
    return self
end