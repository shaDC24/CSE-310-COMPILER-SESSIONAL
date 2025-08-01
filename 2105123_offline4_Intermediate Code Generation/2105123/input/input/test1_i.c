int i,j;
int main(){
 
	int k,ll,m,n,o,p;
	int a[10];
 
	i = 1;
	println(i);
	
	j = 5 + 8;
	println(j);
	
	k = i + 2*j;
	println(k);

	m = k%9;
	println(m);
 
	n = m <= ll;
	println(n);
 
	o = i != j;
	println(o);
 
	p = n || o;
	println(p);
 
	p = n && o;
	println(p);
	
	p++;
	println(p);
 
	k = -p;
	println(k);

	m = 2%-9;
	println(m);	

	a[0]=3;
	a[2]=5;
	m=a[2];
	println(m);
	m=1*1+2*1-1*1+3*3-9+8/2+4%2;
	println(m);	
	return 0;
}

