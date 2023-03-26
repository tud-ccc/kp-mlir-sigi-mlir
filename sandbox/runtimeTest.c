#include "../runtime/sigi.c"

int main(void)
{
    sigi_stack_t* stack = (sigi_stack_t*)malloc(128);
    sigi_init_stack(stack);
    sigi_push_i32(stack, 1);
    sigi_push_i32(stack, 2);
    if (2 != sigi_pop_i32(stack)) {
        printf("2 is wrong\n");
        exit(1);
    }
    if (1 != sigi_pop_i32(stack)) {
        printf("1 is wrong\n");
        exit(1);
    }
    printf("success\n");
    free(stack);
    return 0;
}