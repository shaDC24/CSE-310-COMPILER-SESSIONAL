int main(){
    int a,b,c[3],i;
    a=1*(2+3)%3;
    b= 1<5;
    c[0]=2;
    c[1]=90;
    if(a && b)
        c[0]++;
    else
        c[1]=c[0];
    i=c[1];
    println(i);    
    println(a);
    println(b);

}
