#ifndef SDF_COLLECTOR_INCLUDED
#define SDF_COLLECTOR_INCLUDED

float dot2( in float2 v ) { return dot(v,v); }
float ndot(float2 a, float2 b ) { return a.x*b.x - a.y*b.y; }
float mod(float x, float y) {return x - y * floor(x/y); }

void SDFCircle_float(float2 UV ,float2 p, float1 r, out float1 OutCircle)
{
    p-= UV;
    OutCircle = length(p) - r;
}

void SDFRoundedBox_float(float2 UV, float2 p, float2 scale, float4 roundexCorner , out float1 OutRoundedBox)
{
    p-= UV;
    roundexCorner.xy = (p.x>0.0)?roundexCorner.xy : roundexCorner.zw;
    roundexCorner.x  = (p.y>0.0)?roundexCorner.x  : roundexCorner.y;
    float2 q = abs(p)-scale +roundexCorner.x;
    OutRoundedBox = min(max(q.x,q.y),0.0) + length(max(q,0.0)) - roundexCorner.x;
}

void SDFBox_float(float2 p, float2 b ,out float1 OutSDFBox)
{
    float2 d = abs(p)-b;
    OutSDFBox = length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void SDFOrientedBox_float(float2 UV, float2 p, float2 a, float2 b ,float1 th,out float1 OUTOrientedBox)
{
    p-= UV;
    float l = length(b-a);
    float2  d = (b-a)/l;
    float2  q = (p-(a+b)*0.5);
    //q = mat2(d.x,-d.y,d.y,d.x)*q;
    q = mul(float2(q.x,q.y), float2x2(d.x,-d.y,d.y,d.x));
    q = abs(q)-float2(l,th)*0.5;
    OUTOrientedBox =  length(max(q,0.0)) + min(max(q.x,q.y),0.0);    
}


void SDFSegment_float(float2 UV,float2 p, float2 a, float2 b, out float1 OutSegment)
{
    p-= UV;
    float2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    OutSegment =  length( pa - ba*h );
}

void SDFRhombus_float(float2 UV, float2 p, float2 b , out float1 OutRhombus) 
{
    p += UV;
    p = abs(p); 
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*float2(1.0-h,1.0+h) );
    OutRhombus =  d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}

void SDFTrapezoid_float(float2 UV, float2 p, float1 r1, float1 r2, float1 he, out float1 OutTrapezoid )
{
    p -= UV;
    float2 k1 = float2(r2,he);
    float2 k2 = float2(r2-r1,2.0*he);
    p.x = abs(p.x);
    float2 ca = float2(p.x-min(p.x,(p.y<0.0)?r1:r2), abs(p.y)-he);
    float2 cb = p - k1 + k2*clamp( dot(k1-p,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    OutTrapezoid =  s*sqrt( min(dot2(ca),dot2(cb)) );
}

void SDFParallelogram_float( float2 UV, float2 p, float1 wi, float1 he, float1 sk, out float1 OutParallelogram )
{
    p -= UV;
    float2 e = float2(sk,he);
    p = (p.y<0.0)?-p:p;
    float2  w = p - e; w.x -= clamp(w.x,-wi,wi);
    float2  d = float2(dot(w,w), -w.y);
    float s = p.x*e.y - p.y*e.x;
    p = (s<0.0)?-p:p;
    float2  v = p - float2(wi,0); v -= e*clamp(dot(v,e)/dot(e,e),-1.0,1.0);
    d = min( d, float2(dot(v,v), wi*he-abs(s)));
    OutParallelogram =  sqrt(d.x)*sign(-d.y);
}

void SDFEquilateralTriangle_float( float2 UV, float2 p, float1 scale , out float1 OutEquilateralTriangle)
{
    p -= UV;
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0 * scale;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p = float2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    OutEquilateralTriangle = -length(p)*sign(p.y);
}


void SDFTriangleIsosceles_float( float2 UV, float2 p,float2 q, float1 scale , out float1 OutIsoceleTriangle)
{
    p -= UV;
    p.x = abs(p.x);
    float2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    float2 b = p - q*float2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    float2 d = min( float2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  float2( dot(b,b), s*(p.y-q.y)  ));
    OutIsoceleTriangle =  -sqrt(d.x)*sign(d.y);
}

void SDFTriangle_float( float2 UV, float2 p,float2 p0, float2 p1, float2 p2,  float1 gradientScale, float1 scale , out float1 OutTriangle)
{
    p -= UV * scale;
    float2 e0 = (p1-p0) * gradientScale, e1 = (p2-p1) * gradientScale, e2 = (p0-p2) * gradientScale;
    float2 v0 = (p -p0) * gradientScale, v1 = (p -p1) * gradientScale, v2 = (p -p2) * gradientScale;
    float2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0  );
    float2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    float2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    float2 d = (min(min(float2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     float2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     float2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x))));
    OutTriangle = -sqrt(d.x)*sign(d.y);
}

void SDFUnevenCapsule_float(float2 UV, float2 p, float1 r1, float1 r2, float1 h , float1 scale,out float1 UnevenCapsule )
{
    p -= UV * scale;
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,float2(-b,a));
    if( k < 0.0 )  length(p) - r1;
    if( k > a*h )  length(p-float2(0.0,h)) - r2;
    UnevenCapsule =  dot(p, float2(a,b) ) - r1;
}

void SDFHexagon_float(float2 UV,float2 p, float1 r, out float1 OutHexagon )
{
    p -= UV;
    const float3 k = float3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= float2(clamp(p.x, -k.z*r, k.z*r), r);
    OutHexagon =  length(p)*sign(p.y);
}

void SDFOctogon_float(float2 UV, float2 p, float1 r , out float1 OutOctogon)
{
    p -= UV;
    const float3 k = float3(-0.9238795325, 0.3826834323, 0.4142135623 );
    p = abs(p);
    p -= 2.0*min(dot(float2( k.x,k.y),p),0.0)*float2( k.x,k.y);
    p -= 2.0*min(dot(float2(-k.x,k.y),p),0.0)*float2(-k.x,k.y);
    p -= float2(clamp(p.x, -k.z*r, k.z*r), r);
    OutOctogon =  length(p)*sign(p.y);
}

void SDFHexagram_float(float2 UV,float2 p, float1 r, out float1 OutHexagram )
{
    p -= UV;
    const float4 k = float4(-0.5,0.8660254038,0.5773502692,1.7320508076);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= 2.0*min(dot(k.yx,p),0.0)*k.yx;
    p -= float2(clamp(p.x,r*k.z,r*k.w),r);
    OutHexagram =  length(p)*sign(p.y);
}

void SDFStar5_float(float2 UV,float2 p,  float1 r,  float1 rf, out float1 OutStar5 )
{
    p -= UV;
    const float2 k1 = float2(0.809016994375, -0.587785252292);
    const float2 k2 = float2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    float2 ba = rf*float2(-k1.y,k1.x) - float2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    OutStar5 =  length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}


// A CORRIGER
void SDFStar_float(float2 UV, float2 p,float1 r,float1 n, float1 m, out float1 OutSDFStar)
{
    p -= UV;
    // next 4 lines can be precomputed for a given shape
    const float an = 3.141593/float(n);
    const float en = 3.141593/m;  // m is between 2 and n
    float2  acs = float2(cos(an),sin(an));
    float2  ecs = float2(cos(en),sin(en)); // ecs=vec2(0,1) for regular polygon

    float bn = mod(atan(float2(p.x,p.y)),2.0*an) - an;
    p = length(p)*float2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    OutSDFStar =  length(p)*sign(p.x);
}

void SDFPie_float(float2 UV, float2 p, float2 c, float1 r, out float1 OutSDFPie)
{
    p -= UV;
    p.x = abs(p.x);
    float l = length(p) - r;
    float m = length(p-c*clamp(dot(p,c),0.0,r)); // c=sin/cos of aperture
    OutSDFPie =  max(l,m*sign(c.y*p.x-c.x*p.y));
}

void SDFCutDisk_float(float2 UV,float2 p, float1 r, float1 h, out float1 OutSDFCutDisk )
{
    p -= UV;
    float w = sqrt(r*r-h*h); // constant for any given shape
    p.x = abs(p.x);
    float s = max( (h-r)*p.x*p.x+w*w*(h+r-2.0*p.y), h*p.x-w*p.y );
    OutSDFCutDisk =  (s<0.0) ? length(p)-r :
           (p.x<w) ? h - p.y     :
                     length(p-float2(w,h));
}

void SDFArc_float(float2 UV, float2 p, float2 sc,  float1 ra, float1 rb, out float1 OutSDFArc )
{
    p += UV;
    // sc is the sin/cos of the arc's aperture
    p.x = abs(p.x);
    OutSDFArc =  ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}



void SDFEgg_float(float2 UV ,float2 p, float2 ra, float1 rb, out float1 OutEgg)
{
    p += UV;
    const float k = sqrt(3.0);
    p.x = abs(p.x);
    float r = ra - rb;
    OutEgg =  ((p.y<0.0)       ? length(float2(p.x,  p.y    )) - r :
            (k*(p.x+r)<p.y) ? length(float2(p.x,  p.y-k*r)) :
                              length(float2(p.x+r,p.y    )) - 2.0*r) - rb;
}


void SDFHeart_float( float2 UV ,float2 p, float1 scale, out float1 OutSDFHeart )
{
    p -= UV;
    p /=10;
    p.x = abs(p.x);
    if( p.y+p.x>1.0 )
    {
        sqrt(dot2(p-float2(0.25,0.75))) - sqrt(2.0)/4.0;
    }
    OutSDFHeart =  sqrt(min(dot2(p-float2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}


void SDFStairs_float(float2 UV ,in float2 p, float2 wh, float1 n ,out float1 OutStairs)
{
    p -=UV;
    float2 ba = wh*n;
    float d = min(dot2(p-float2(clamp(p.x,0.0,ba.x),0.0)), 
                  dot2(p-float2(ba.x,clamp(p.y,0.0,ba.y))) );
    float s = sign(max(-p.y,p.x-ba.x) );

    float dia = length(wh);
    //p = float2x2(wh.x,-wh.y, wh.y,wh.x)*p/dia;
    //Inverser les escaliers, on voit le tracé plutot que les escaliers 
    //p = mul(float2x2(wh.x, -wh.y,wh.y,wh.x), float2(p.x,p.y))/dia;
    p = mul(float2(p.x,p.y),float2x2(wh.x, -wh.y,wh.y,wh.x))/dia;
    
    float id = clamp(round(p.x/dia),0.0,n-1.0);
    p.x = p.x - id*dia;
    //float2x2 not working
    //p = float2x2(wh.x, wh.y,-wh.y,wh.x)*p/dia;
    p = mul(float2(p.x,p.y),float2x2(wh.x, wh.y,-wh.y,wh.x))/dia;
    
    float hh = wh.y/2.0;
    p.y -= hh;
    if( p.y>hh*sign(p.x) ) s=1.0;
    p = (id<0.5 || p.x>0.0) ? UV - p : -p;
    //Appliquer un gradient
    //d = min( d, dot2(p-float2(0.0,clamp(p.y,-hh,hh))) );
    //d = min( d, dot2(p-float2(clamp(p.x,0.0,wh.x),hh)) );
    
    OutStairs =  sqrt (d)*s;
}



#endif