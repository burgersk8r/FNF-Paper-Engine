package funkin.backend.system.macros;

#if !macro
import haxe.macro.Expr.Field;
import haxe.macro.Context;
#end
#if sys
import sys.io.File;
#end

class BuildNumber {
    // non functional
    public static macro function getBuildNumber():haxe.macro.Expr.ExprOf<Int> {
        #if !display
        var buildNum:Int = Std.parseInt(File.getContent("assets/data/buildNum.txt"));
        return macro $v{buildNum};
        #else
        return macro $v{0};
        #end
    }
}