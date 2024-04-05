.data

.text
    formatstr:      .asciz "%lu"
    format_out:     .asciz "%lu "
    input_num:      .asciz "Enter the number of elements: "
    input_element:  .asciz "Enter %lu space-separated integers: "
    output_str:     .asciz "Sorted array: "
    
.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp                   # allocate space for two quadword variable on the stack
    
    leaq    input_num(%rip), %rdi
    call    printf
    
    leaq    -8(%rbp), %rsi              # load address of the variable to store user input
    leaq    formatstr(%rip), %rdi
    call    scanf

    imulq   $8, %rax, %rdi
    call    malloc                      # int* arr = (int*)malloc(n * sizeof(long));
    movq    %rax, %r13

    movq    -8(%rbp), %rsi
    leaq    input_element(%rip), %rdi
    call    printf                      # printf("Enter %d space-separated integers: ", n)
    movq    $0, %r15 

input_loop:
    leaq    -16(%rbp), %rsi              # take input one by one
    leaq    formatstr(%rip), %rdi
    call    scanf

    movq    -16(%rbp), %rax
    movq    %rax, (%r13, %r15, 8)

    incq    %r15

    cmpq    -8(%rbp), %r15
    jl      input_loop

call_func:
    movq    %r13, %rdi                  # move arr to first arg
    movq    $0, %rsi                    # move 0 to second arg
    movq    -8(%rbp), %rdx
    decq    %rdx                        # n-1 to third arg
    call    quicksort
    
    leaq    output_str(%rip), %rdi      # load address of the output format string for printf
    call    printf 
    movq    $0, %r15          
    
print_loop:
    movq    (%r13, %r15, 8), %rsi
    leaq    format_out(%rip), %rdi
    call    printf

    incq    %r15

    cmpq    -8(%rbp), %r15
    jl      print_loop

exit:
    movq    %rbp, %rsp
    popq    %rbp
    
    movq    $0, %rax
    ret

# Args: rdi = arr, rsi = low, rdx = high
# Global: arr = %r13, partition index = %r14, loop counter = %r15
quicksort:
    pushq   %rbp
    movq    %rsp, %rbp

    cmpq    %rdx, %rsi
    jge     end_sort                    # If high >= low, exit the recursion

    pushq   %rdx
    pushq   %rsi

    call    partition
    movq    %rax, %r14

    movq    %r13, %rdi
    popq    %rsi
    movq    %r14, %rdx
    decq    %rdx
    call    quicksort                   # quickSort(arr, low, partitionIndex - 1)

    movq    %r13, %rdi
    movq    %r14, %rsi
    incq    %rsi
    popq    %rdx
    call    quicksort                   # quickSort(arr, partitionIndex + 1, high)

end_sort:
    movq    %rbp, %rsp
    popq    %rbp
    ret

# Global: pivot = %r12, arr = %r13, temp = %r14, i = %r15, j = %rcx
partition:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %r14                        # save partition index just in case

    movq    (%r13, %rdx, 8), %r12       # pivot = arr[high]

    movq    %rsi, %r15                  # i = low-1
    decq    %r15
    movq    %rsi, %rcx                  # j = low

partition_loop:
    cmpq    %rdx, %rcx
    jge     skip_swap                   # If high >= j, skip swapping

    movq    (%r13, %rcx, 8), %r14       
    cmpq    %r12, %r14 
    jge     inc_j                       # pivot >= arr[j]

    incq    %r15
    movq    (%r13, %r15, 8), %r14       # temp = arr[i]
    pushq   %r14
    movq    (%r13, %rcx, 8), %r14       # arr[j]
    movq    %r14, (%r13, %r15, 8)       # arr[i] = arr[j]
    popq    %r14
    movq    %r14, (%r13, %rcx, 8)       # arr[j] = temp

    incq    %rcx
    jmp     partition_loop

inc_j:
    incq    %rcx
    jmp     partition_loop

skip_swap:
    incq    %r15
    movq    (%r13, %r15, 8), %r14       # temp = arr[i]
    pushq   %r14
    movq    (%r13, %rdx, 8), %r14       # arr[high]
    movq    %r14, (%r13, %r15, 8)       # arr[i] = arr[high]
    popq    %r14
    movq    %r14, (%r13, %rdx, 8)       # arr[high] = temp

    movq    %r15, %rax
    popq    %r14

    movq    %rbp, %rsp
    popq    %rbp
    ret
