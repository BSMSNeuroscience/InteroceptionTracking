% SET_PRIORITY Sets the priority of a process
%
%    SET_PRIORITY(process_id, priority_class, thread_priority) 
%    
%    Process ID
%    Process ID -1 will set the Process priority class and thread priority
%    of the current process and thread. If a positive number is input
%    as process ID, this command will change the priority class of that
%    process if allowed by windows security. The thread priority is ignored
%    in this latter case. You can use the command !tasklist to obtain 
%    process ids of running processes.
%
%    Process Priority Classes:
% 
%    Constant Name                 Hex WinValue     Argument Value
%    IDLE_PRIORITY_CLASS           0x00000040             1
%    BELOW_NORMAL_PRIORITY_CLASS   0x00004000             2
%    NORMAL_PRIORITY_CLASS         0x00000020             3
%    ABOVE_NORMAL_PRIORITY_CLASS   0x00008000             4
%    HIGH_PRIORITY_CLASS           0x00000080             5
%    REALTIME_PRIORITY_CLASS       0x00000100             6
% 
%    Thread Priotity:
%
%    Constant Name                  WinValue        Argument Value
%    THREAD_PRIORITY_IDLE             -15                 1
%    THREAD_PRIORITY_LOWEST            -2                 2
%    THREAD_PRIORITY_BELOW_NORMAL      -1                 3
%    THREAD_PRIORITY_NORMAL             0                 4
%    THREAD_PRIORITY_ABOVE_NORMAL       1                 5
%    THREAD_PRIORITY_HIGHEST            2                 6
%    THREAD_PRIORITY_TIME_CRITICAL     15                 7
%
function set_priority(process_id, pri_class, pri_thread)

set_prio(process_id, pri_class, pri_thread);
end
