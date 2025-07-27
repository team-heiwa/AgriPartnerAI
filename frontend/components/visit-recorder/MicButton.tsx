'use client'

import React, { useState, useEffect, useRef } from 'react'

interface MicButtonProps {
  isRecording: boolean
  onToggle: () => void
}

export default function MicButton({ isRecording, onToggle }: MicButtonProps) {
  const [audioLevel, setAudioLevel] = useState(0)
  const [recordingTime, setRecordingTime] = useState(0)
  const audioContextRef = useRef<AudioContext | null>(null)
  const analyzerRef = useRef<AnalyserNode | null>(null)
  const intervalRef = useRef<NodeJS.Timeout | null>(null)

  useEffect(() => {
    if (isRecording) {
      startRecording()
      startTimer()
    } else {
      stopRecording()
      stopTimer()
    }

    return () => {
      stopRecording()
      stopTimer()
    }
  }, [isRecording])

  const startTimer = () => {
    setRecordingTime(0)
    intervalRef.current = setInterval(() => {
      setRecordingTime(prev => prev + 1)
    }, 1000)
  }

  const stopTimer = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current)
      intervalRef.current = null
    }
  }

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      audioContextRef.current = new AudioContext()
      const source = audioContextRef.current.createMediaStreamSource(stream)
      analyzerRef.current = audioContextRef.current.createAnalyser()
      
      analyzerRef.current.fftSize = 256
      source.connect(analyzerRef.current)
      
      updateAudioLevel()
    } catch (error) {
      console.error('マイクアクセスエラー:', error)
    }
  }

  const stopRecording = () => {
    if (audioContextRef.current) {
      audioContextRef.current.close()
      audioContextRef.current = null
    }
    setAudioLevel(0)
  }

  const updateAudioLevel = () => {
    if (!analyzerRef.current) return

    const dataArray = new Uint8Array(analyzerRef.current.frequencyBinCount)
    analyzerRef.current.getByteFrequencyData(dataArray)
    
    const average = dataArray.reduce((sum, value) => sum + value, 0) / dataArray.length
    setAudioLevel(average / 255 * 100)

    if (isRecording) {
      requestAnimationFrame(updateAudioLevel)
    }
  }

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  return (
    <div className="space-y-4">
      {/* マイクボタン */}
      <div className="flex justify-center">
        <button
          onClick={onToggle}
          className={`
            w-20 h-20 rounded-full flex items-center justify-center text-2xl
            transition-all transform hover:scale-105
            ${isRecording 
              ? 'bg-risk-alert text-white animate-pulse' 
              : 'bg-gray-200 text-gray-600 hover:bg-gray-300'
            }
          `}
        >
          {isRecording ? '⏹️' : '🎙️'}
        </button>
      </div>

      {/* 録音状態表示 */}
      {isRecording && (
        <div className="text-center space-y-3">
          <div className="text-lg font-mono text-risk-alert">
            {formatTime(recordingTime)}
          </div>
          
          {/* 音声レベルバー */}
          <div className="space-y-2">
            <div className="text-sm text-gray-600">音声レベル</div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="h-2 rounded-full bg-green-500 transition-all duration-100"
                style={{ width: `${audioLevel}%` }}
              ></div>
            </div>
          </div>

          {/* 15分分割の警告 */}
          {recordingTime > 0 && recordingTime % 900 === 0 && (
            <div className="text-xs text-yellow-600 bg-yellow-50 p-2 rounded">
              ⚠️ 15分経過しました。自動分割されます。
            </div>
          )}
        </div>
      )}

      {!isRecording && recordingTime > 0 && (
        <div className="text-center text-sm text-gray-600">
          最後の録音: {formatTime(recordingTime)}
        </div>
      )}

      {/* 録音のヒント */}
      <div className="text-xs text-gray-500 text-center space-y-1">
        <p>💡 ボタンを押して録音開始・停止</p>
        <p>📝 音声は自動的に文字起こしされます</p>
      </div>
    </div>
  )
}