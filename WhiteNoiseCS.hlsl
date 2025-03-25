RWTexture2D<float4> PerlinTexture : register(u0); // UAV Ŀ������
cbuffer CB : register(b0)
{
    float2 NoiseScale; // ��������ϸ�� (�Ŵ���������)
    float scale;
}


// ��ǿ�Ĺ�ϣ�������������ǿ��
uint Hash(int x, int y)
{
    uint a = (x * 1836311903) + (y * 2971215073);
    a = (a ^ (a >> 16)) * 0x85ebca6b;
    a = (a ^ (a >> 13)) * 0xc2b2ae35;
    a = a ^ (a >> 16);
    return a & 7; // ����һ�� 0-7 ֮���ֵ
}
float fract(float x) {
    return x - floor(x);
}
float WhiteNoise(float x, float y)
{
    return fract(sin(dot(float2(x,y),NoiseScale))*scale);

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
    float noiseValue = WhiteNoise(uv.x * NoiseScale.x, uv.y * NoiseScale.y);

    // ������ֵд��Ŀ������
    PerlinTexture[id.xy] = float4(noiseValue, noiseValue, noiseValue, 1);
}
