package funkin.backend.system.framerate;

#if cpp @:include('./memory.h')
extern #end class Memory {

	#if cpp
	@:native("get_memory_usage")
	static public function getProcessMemory(): Float;
	#else 
	static public inline function getProcessMemory(): Float {
		return -1;
	}
	#end
	static public inline function getGCMemory(): Float {
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#else
		return 0;
		#end
	}
}