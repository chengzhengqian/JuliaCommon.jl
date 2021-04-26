#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h> //for mmap

#define ptr_byte uint8_t *
ptr_byte create_page(size_t page_size) {
  int property = PROT_READ | PROT_WRITE;
  int flags = MAP_ANONYMOUS | MAP_PRIVATE;
  uint8_t *page = (uint8_t *)mmap(NULL, page_size, property, flags, -1, 0);
  return page;
}

ptr_byte create_page_exec(size_t page_size) {
  int property = PROT_READ | PROT_WRITE| PROT_EXEC;
  int flags = MAP_ANONYMOUS | MAP_PRIVATE;
  uint8_t *page = (uint8_t *)mmap(NULL, page_size, property, flags, -1, 0);
  return page;
}

int set_page_exec(ptr_byte page, size_t page_size) {
  mprotect(page, page_size, PROT_READ | PROT_EXEC);
  return 0;
}

void free_page(ptr_byte page, size_t page_size) { munmap(page, page_size); }

ptr_byte loadBinary(const char* filename, size_t * ptr_page_size){
  /* we already compile the corresponding file, using :   ld --oformat binary */
  FILE *fptr=fopen(filename,"rb");
  fseek(fptr,0L,SEEK_END);
  (*ptr_page_size)=ftell(fptr);
  fseek(fptr,0L,SEEK_SET);
  printf("loading file %s with size  %ld\n",filename,*ptr_page_size);
  ptr_byte code=create_page(*ptr_page_size);
  fread(code,*ptr_page_size,1,fptr);
  fclose(fptr);
  set_page_exec(code,*ptr_page_size);
  return code;
  /* int (*func)(); */
  /* func=(int(*)())code; */
  /* int result=func(); */
  /* printf("result is %d\n",result); */
}


/* int runCode(){ */
/*   /\* we try a hard coded example *\/ */
/*   int num_bytes=6; */
/*   ptr_byte code=create_page(num_bytes); */
/*   code[0]=0xb8; */
/*   code[1]=0x7b; */
/*   code[2]=0x00; */
/*   code[3]=0x00; */
/*   code[4]=0x00; */
/*   code[5]=0xc3; */
/*   set_page_exec(code,num_bytes); */
/*   int (*func)(); */
/*   func=(int(*)())code; */
/*   int result=func(); */
/*   printf("result is %d\n",result); */
/*   free_page(code,num_bytes); */
/* } */

/* int printString(char *c){ */
/*   printf("input is %s\n",c); */
/* } */

/* int show(){ */
/*   printf("this is just a test\n"); */
/* } */



  
  
