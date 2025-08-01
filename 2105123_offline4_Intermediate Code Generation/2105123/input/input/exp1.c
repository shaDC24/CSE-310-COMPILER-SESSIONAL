int main(){
    int a,b,c[3],i;
    a=1*(2+3)%3;
    b= 1<5;
    c[0]=2; 
    if(a || b)
         i=a;
    else
        i=b;   
    println(a);
    println(b);
    println(i);          
    if(a && b)
        i=a;
    else
        i=b;

    println(a);
    println(b);
    println(i);
    if(a+b<=5)
        i=b;
    else 
        i=a;
    println(a);
    println(b);
    println(i);           
    return 0;
}
