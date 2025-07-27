'use client'

import React, { useState, useRef, useEffect } from 'react'

interface VideoPreviewProps {
  isRecording: boolean
}

export default function VideoPreview({ isRecording }: VideoPreviewProps) {
  const [capturedImages, setCapturedImages] = useState<string[]>([])
  const [isStreaming, setIsStreaming] = useState(false)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    startCamera()
    return () => {
      stopCamera()
    }
  }, [])

  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: { width: 640, height: 480 },
        audio: false 
      })
      if (videoRef.current) {
        videoRef.current.srcObject = stream
        setIsStreaming(true)
      }
    } catch (error) {
      console.error('カメラアクセスエラー:', error)
    }
  }

  const stopCamera = () => {
    if (videoRef.current && videoRef.current.srcObject) {
      const tracks = (videoRef.current.srcObject as MediaStream).getTracks()
      tracks.forEach(track => track.stop())
      setIsStreaming(false)
    }
  }

  const captureImage = () => {
    if (!videoRef.current || !canvasRef.current) return

    const canvas = canvasRef.current
    const video = videoRef.current
    const ctx = canvas.getContext('2d')

    if (!ctx) return

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    ctx.drawImage(video, 0, 0)

    const imageData = canvas.toDataURL('image/jpeg', 0.8)
    setCapturedImages(prev => [imageData, ...prev.slice(0, 4)]) // 最大5枚まで保持

    console.log('画像キャプチャ完了')
  }

  return (
    <div className="space-y-4">
      {/* ビデオプレビュー */}
      <div className="relative bg-black rounded-lg overflow-hidden aspect-video">
        {isStreaming ? (
          <video
            ref={videoRef}
            autoPlay
            muted
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-white">
            <div className="text-center">
              <span className="text-4xl block mb-2">📹</span>
              <p>カメラを起動中...</p>
            </div>
          </div>
        )}
        
        {/* 録画インジケーター */}
        {isRecording && (
          <div className="absolute top-2 left-2 flex items-center gap-2">
            <div className="w-3 h-3 bg-risk-alert rounded-full animate-pulse"></div>
            <span className="text-white text-sm font-semibold">REC</span>
          </div>
        )}
      </div>

      {/* 撮影ボタン */}
      <div className="flex justify-center">
        <button
          onClick={captureImage}
          disabled={!isStreaming}
          className="bg-blue-600 text-white px-6 py-3 rounded-full hover:bg-blue-700 disabled:bg-gray-400 transition-colors"
        >
          📸 撮影
        </button>
      </div>

      {/* キャプチャしたサムネイル */}
      {capturedImages.length > 0 && (
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">撮影済み画像</h3>
          <div className="flex gap-2 overflow-x-auto pb-2">
            {capturedImages.map((image, index) => (
              <img
                key={index}
                src={image}
                alt={`Captured ${index + 1}`}
                className="w-16 h-12 object-cover rounded border-2 border-gray-200 flex-shrink-0 cursor-pointer hover:border-blue-400"
                onClick={() => console.log('画像詳細表示', index)}
              />
            ))}
          </div>
        </div>
      )}

      {/* 隠しcanvas要素 */}
      <canvas ref={canvasRef} className="hidden" />
    </div>
  )
}