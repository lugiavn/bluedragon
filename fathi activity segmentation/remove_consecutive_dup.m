function str = remove_consecutive_dup( str )
%REMOVE_CONSECUTIVE_DUP remove consecutive duplicate from string
%   remove consecutive duplicate from string
    
    for i=length(str):-1:2
       if str(i) == str(i-1)
           str(i) = [];
       end
    end

end

