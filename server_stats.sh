#/bin/sh

#design variables with unicode symbols
HELLO="komardinec/top-a-like\u2122"
WIDE_SEPARATOR_START="\u250C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
WIDE_SEPARATOR_END="\u2514\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
WIDE_SEPARATOR_INSIDE="\u251C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
SIDE_POINTER_INSIDE="\u251C"

#variables for command text substitution
UPTIME="uptime"
MEMORY="free --human --giga --total -w"

#initial variables for cpu usage information
PROC_STAT_INIT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print}')
US_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $2}')
NICE_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $3}')
SYS_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $4}')
IDLE_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $5}')
IOWAIT_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $6}')
IRQ_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $7}')
SIRQ_CPU_PREV=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $8}')
CPU_TOTAL_PREV=0
for VALUE in $PROC_STAT; do # loop to summarize total cpu usage
  let "CPU_TOTAL_PREV=$CPU_TOTAL_PREV+$VALUE"
done

cpu() { # function will read infromation about cpu usage from system file /proc/stat
  # it should take 2 reads before showing cpu usage
  PROC_STAT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print}')

  US_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $2}')
  NICE_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $3}')
  SYS_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $4}')
  IDLE_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $5}')
  IOWAIT_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $6}')
  IRQ_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $7}')
  SIRQ_CPU_CURRENT=$(cat /proc/stat | grep '^cpu ' | awk '{$1=""; print $8}')

  CPU_TOTAL=0
  for VALUE in $PROC_STAT; do
    let "CPU_TOTAL=$CPU_TOTAL+$VALUE"
  done
  CPU_TOTAL_DELTA=$(($CPU_TOTAL - $CPU_TOTAL_PREV))

  US_CPU_DELTA=$(($US_CPU_CURRENT - $US_CPU_PREV))
  NICE_CPU_DELTA=$(($NICE_CPU_CURRENT - $NICE_CPU_PREV))
  SYS_CPU_DELTA=$(($SYS_CPU_CURRENT - $SYS_CPU_PREV))
  IDLE_CPU_DELTA=$(($IDLE_CPU_CURRENT - $IDLE_CPU_PREV))
  IOWAIT_CPU_DELTA=$(($IOWAIT_CPU_CURRENT - $IOWAIT_CPU_PREV))
  IRQ_CPU_DELTA=$(($IRQ_CPU_CURRENT - $IRQ_CPU_PREV))
  SIRQ_CPU_DELTA=$(($SIRQ_CPU_CURRENT - $SIRQ_CPU_PREV))

  let "US_CPU_PERCENT = 100 * US_CPU_DELTA / CPU_TOTAL_DELTA"
  let "NICE_CPU_PERCENT = 100 * NICE_CPU_DELTA / CPU_TOTAL_DELTA"
  let "SYS_CPU_PERCENT = 100 * SYS_CPU_DELTA / CPU_TOTAL_DELTA"
  let "IDLE_CPU_PERCENT = 100 * IDLE_CPU_DELTA / CPU_TOTAL_DELTA"
  let "IOWAIT_CPU_PERCENT = 100 * IOWAIT_CPU_DELTA / CPU_TOTAL_DELTA"
  let "IRQ_CPU_PERCENT = 100 * IRQ_CPU_DELTA / CPU_TOTAL_DELTA"
  let "SIRQ_CPU_PERCENT = 100 * SIRQ_CPU_DELTA / CPU_TOTAL_DELTA"

  printf " CPU(s, %%):  $US_CPU_PERCENT usr,  $NICE_CPU_PERCENT nice,  $SYS_CPU_PERCENT sys,  $IDLE_CPU_PERCENT idle,  $IOWAIT_CPU_PERCENT iow,  $IRQ_CPU_PERCENT hi,  $SIRQ_CPU_PERCENT si\n"

  CPU_TOTAL_PREV="$CPU_TOTAL"
  US_CPU_PREV="$US_CPU_CURRENT"
  NICE_CPU_PREV="$NICE_CPU_CURRENT"
  SYS_CPU_PREV="$SYS_CPU_CURRENT"
  IDLE_CPU_PREV="$IDLE_CPU_CURRENT"
  IOWAIT_CPU_PREV="$IOWAIT_CPU_CURRENT"
  IRQ_CPU_PREV="$IRQ_CPU_CURRENT"
  SIRQ_CPU_PREV="$SIRQ_CPU_CURRENT"
}

disk() { # info from df -h with custom output format
  WIDTH=23
  DISK_INFO=$(df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs | sort -hk 2 | grep -v "efivars")
  DEVICE_COUNT=$(echo "$DISK_INFO" | wc -l)
  for ((i = 1; i <= $DEVICE_COUNT; ++i)); do
    DEVICE=$(echo "$DISK_INFO" | sed -n ''"$i"'p')
    for LINE in "$DEVICE"; do
      MEM_FS=$(echo "$LINE" | awk '{print $1}')
      MEM_TOTAL=$(echo "$LINE" | awk '{print $2}')
      MEM_USED=$(echo "$LINE" | awk '{print $3}')
      MEM_FREE=$(echo "$LINE" | awk '{print $4}')
      MEM_USED_PERCENT=$(echo "$LINE" | awk '{print $5}')
      MEM_MOUNT=$(echo "$LINE" | awk '{print $6}')
      printf "$SIDE_POINTER_INSIDE "
      printf "%s%*s%s%*s%s%*s%s%*s%s%*s%s\n" $MEM_FS $(($WIDTH - ${#MEM_FS})) "" $MEM_TOTAL $(($WIDTH - ${#MEM_TOTAL})) "" $MEM_USED $((24 - ${#MEM_USED})) "" $MEM_FREE $(($WIDTH - ${#MEM_FREE})) "" $MEM_USED_PERCENT $(($WIDTH - ${#MEM_USED_PERCENT})) "" $MEM_MOUNT
    done
  done
}

memory() { # support function to add style for output of 'free' command
  MEMORY_INFO=$($MEMORY)
  MEMORY_INFO_COUNT=$(echo "$MEMORY_INFO" | wc -l)
  for ((i = 1; i <= $MEMORY_INFO_COUNT; ++i)); do
    MEMORY_INFO_LINE=$(echo "$MEMORY_INFO" | sed -n ''"$i"'p')
    printf "$SIDE_POINTER_INSIDE $MEMORY_INFO_LINE\n"
  done
}

proc_by_cpu() { # function will show top 5 processes sorted by % of cpu time usage
  PROC_BY_CPU=$(ps -ao user,pid,ni,cpu,pmem,stat,cmd | sort -r -k 4 | head -6)
  PROC_BY_CPU_COUNT=$(echo "$PROC_BY_CPU" | wc -l)
  for ((i = 1; i <= $PROC_BY_CPU_COUNT; ++i)); do
    PROC_BY_CPU_LINE=$(echo "$PROC_BY_CPU" | sed -n ''"$i"'p')
    echo -e "$SIDE_POINTER_INSIDE $PROC_BY_CPU_LINE"
  done
}

proc_by_mem() { # function will show top 5 processes sorted by memory usage
  PROC_BY_MEM=$(ps -ao user,pid,ni,cpu,pmem,stat,cmd | sort -r -k 5 | head -6)
  PROC_BY_MEM_COUNT=$(echo "$PROC_BY_MEM" | wc -l)
  for ((i = 1; i <= $PROC_BY_MEM_COUNT; ++i)); do
    PROC_BY_MEM_LINE=$(echo "$PROC_BY_MEM" | sed -n ''"$i"'p')
    echo -e "$SIDE_POINTER_INSIDE $PROC_BY_MEM_LINE"
  done
}

information() { # main executable function
  while true; do
    clear
    printf "$WIDE_SEPARATOR_START\n"
    printf "$SIDE_POINTER_INSIDE $HELLO -$($UPTIME)\n"
    printf "$WIDE_SEPARATOR_INSIDE\n"
    printf "$SIDE_POINTER_INSIDE"
    cpu
    printf "$WIDE_SEPARATOR_INSIDE\n"
    memory
    printf "$WIDE_SEPARATOR_INSIDE\n"
    disk
    printf "$WIDE_SEPARATOR_INSIDE\n"
    printf "$SIDE_POINTER_INSIDE"
    printf " Top 5 processes sorted by CPU%%\n"
    proc_by_cpu
    printf "$WIDE_SEPARATOR_INSIDE\n"
    printf "$SIDE_POINTER_INSIDE"
    printf " Top 5 processes sorted by MEM\n"
    proc_by_mem
    printf "$WIDE_SEPARATOR_END\n"
    sleep 2
  done
}

information # start execution
