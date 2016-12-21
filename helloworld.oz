%% ozc -c helloworld.oz
%% ozengine helloworld.ozf
functor
import
     Application
     System
define
    {System.showInfo 'Hola, Mundo'}
    {Application.exit 0} 
end
