using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SHCreator : MonoBehaviour
{
    public ComputeShader cShader;
    public Material mat;
    public Cubemap envCubeMap;
    public Vector3 SHRotation;
    public float rotateSpeed = 30f;

    private ComputeBuffer SHBuffer;

    void Awake()
    {
        SHBuffer = new ComputeBuffer(9, 16);

        int kernel = cShader.FindKernel("CSMain");
        cShader.SetBuffer(kernel, "RWSHBuffer", SHBuffer);
        cShader.SetTexture(kernel, "CubeMap", envCubeMap);
        cShader.Dispatch(kernel, 9, 1, 1);

        mat.SetBuffer("SHbuffer", SHBuffer);
    }

    void Update() 
    {
        // rotate around Y axis
        Quaternion rot = Quaternion.Euler(0,Time.time * rotateSpeed,0);
        Matrix4x4 shRotationMatrix = Matrix4x4.TRS(Vector3.zero, rot, Vector3.one);
        mat.SetMatrix("shRotMatrix",shRotationMatrix);
    }

    private void OnDisable()
    {
        if (SHBuffer != null)
        {
            SHBuffer.Dispose();

            SHBuffer = null;
        }
    }
}
