RWTexture2D<float4> PerlinTexture : register(u0); // UAV Ŀ������
cbuffer CB : register(b0)
{
    float2 NoiseScale; // ��������ϸ�� (�Ŵ���������)
}

// �ݶȷ�����ǿ�ݶȶ����ԣ�
static const float2 Gradients[8] =
{
    float2(1, 0), float2(-1, 0), float2(0, 1), float2(0, -1),
    float2(0.707, 0.707), float2(-0.707, 0.707), float2(0.707, -0.707), float2(-0.707, -0.707)
};

// ��ǿ�Ĺ�ϣ�������������ǿ��
uint Hash(int x, int y)
{
    uint a = (x * 1836311903) + (y * 2971215073);
    a = (a ^ (a >> 16)) * 0x85ebca6b;
    a = (a ^ (a >> 13)) * 0xc2b2ae35;
    a = a ^ (a >> 16);
    return a & 7; // ����һ�� 0-7 ֮���ֵ
}

// ��ȡ�ݶȵ��
float GradientDot(int ix, int iy, float x, float y)
{
    float2 gradient = Gradients[Hash(ix, iy)];
    return dot(gradient, float2(x - ix, y - iy));
}

// Hermite S �����ߣ�ƽ����ֵ��
float Fade(float t)
{
    //return 3*t*t - 2*t*t*t;
    return t * t * t * (t * (t * 6 - 15) + 10);
}

// Perlin ��������
float PerlinNoise(float x, float y)
{
    int x0 = (int) floor(x);
    int y0 = (int) floor(y);
    int x1 = x0 + 1;
    int y1 = y0 + 1;

    float sx = Fade(x - x0);
    float sy = Fade(y - y0);

    float n0 = GradientDot(x0, y0, x, y);
    float n1 = GradientDot(x1, y0, x, y);
    float ix0 = lerp(n0, n1, sx);

    float n2 = GradientDot(x0, y1, x, y);
    float n3 = GradientDot(x1, y1, x, y);
    float ix1 = lerp(n2, n3, sx);

    return lerp(ix0, ix1, sy) * 0.5 + 0.5; // ��һ���� [0,1]
}


// Compute Shader ������
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    int2 dims;
    PerlinTexture.GetDimensions(dims.x, dims.y);

    // ���㵱ǰ���ص� UV ����
    float2 uv = float2(id.xy) / float2(dims);

    // ʹ�ö��طֱ����������ɸ��ӵ�����ͼ
    float noiseValue = PerlinNoise(uv.x * NoiseScale.x, uv.y * NoiseScale.y);

    // ������ֵд��Ŀ������
    PerlinTexture[id.xy] = float4(noiseValue, noiseValue, noiseValue, 1);
}
