'use client'

import React, { useState, useRef, useEffect } from 'react'

interface VoiceMemoModalProps {
  isOpen: boolean
  onClose: () => void
  actionId: string | null
}

export default function VoiceMemoModal({ isOpen, onClose, actionId }: VoiceMemoModalProps) {
  const [isRecording, setIsRecording] = useState(false)
  const [recordingTime, setRecordingTime] = useState(0)
  const [audioLevel, setAudioLevel] = useState(0)
  const [memos, setMemos] = useState<Array<{
    id: string
    timestamp: Date
    duration: number
    transcription: string
    audioUrl?: string
  }>>([
    {
      id: '1',
      timestamp: new Date('2024-01-15T14:30:00'),
      duration: 45,
      transcription: '換気設定を確認しました。現在は80%で稼働中。30%減少させると50%になります。',
      audioUrl: '#'
    },
    {
      id: '2',
      timestamp: new Date('2024-01-15T15:20:00'),
      duration: 32,
      transcription: '湿度センサーの値を確認。現在92%です。換気量を調整後、再度測定する予定。',
      audioUrl: '#'
    }
  ])

  const intervalRef = useRef<NodeJS.Timeout | null>(null)
  const audioContextRef = useRef<AudioContext | null>(null)
  const analyzerRef = useRef<AnalyserNode | null>(null)

  useEffect(() => {
    if (isRecording) {
      startTimer()
      startAudioVisualization()
    } else {
      stopTimer()
      stopAudioVisualization()
    }

    return () => {
      stopTimer()
      stopAudioVisualization()
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

  const startAudioVisualization = async () => {
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

  const stopAudioVisualization = () => {
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

  const handleStartRecording = () => {
    setIsRecording(true)
  }

  const handleStopRecording = () => {
    setIsRecording(false)
    
    // 音声メモを保存（実際にはAPIに送信）
    const newMemo = {
      id: `memo_${Date.now()}`,
      timestamp: new Date(),
      duration: recordingTime,
      transcription: '音声認識中... 新しいメモが追加されました。', // 実際には音声認識APIの結果
      audioUrl: '#'
    }

    setMemos(prev => [newMemo, ...prev])
    setRecordingTime(0)
  }

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  const formatDateTime = (date: Date) => {
    return date.toLocaleString('ja-JP', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* ヘッダー */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-bold text-gray-800">🎤 音声メモ</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 text-xl"
          >
            ×
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* アクション情報 */}
          {actionId && (
            <div className="bg-blue-50 rounded-lg p-3 border border-blue-200">
              <div className="text-sm text-blue-800">
                <strong>関連アクション:</strong> {actionId}
              </div>
              <div className="text-xs text-blue-600 mt-1">
                換気30%減少 - 灰色かび病対策
              </div>
            </div>
          )}

          {/* 録音コントロール */}
          <div className="text-center space-y-4">
            <div className="flex justify-center">
              <button
                onClick={isRecording ? handleStopRecording : handleStartRecording}
                className={`
                  w-20 h-20 rounded-full flex items-center justify-center text-2xl
                  transition-all transform hover:scale-105 shadow-lg
                  ${isRecording 
                    ? 'bg-red-500 text-white animate-pulse' 
                    : 'bg-blue-500 text-white hover:bg-blue-600'
                  }
                `}
              >
                {isRecording ? '⏹️' : '🎤'}
              </button>
            </div>

            {isRecording && (
              <div className="space-y-3">
                <div className="text-lg font-mono text-red-500">
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

                <div className="text-xs text-gray-500">
                  🔴 録音中... クリックで停止
                </div>
              </div>
            )}

            {!isRecording && (
              <div className="text-sm text-gray-600">
                マイクボタンをクリックして録音開始
              </div>
            )}
          </div>

          {/* 保存済みメモ一覧 */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700 flex items-center gap-2">
              📝 保存済みメモ ({memos.length})
            </h3>
            
            <div className="space-y-3 max-h-64 overflow-y-auto">
              {memos.map((memo) => (
                <div
                  key={memo.id}
                  className="border border-gray-200 rounded-lg p-3 hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="text-xs text-gray-500">
                      {formatDateTime(memo.timestamp)}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-gray-500">
                        {formatTime(memo.duration)}
                      </span>
                      <button className="text-blue-600 hover:text-blue-800 text-sm">
                        ▶️
                      </button>
                    </div>
                  </div>
                  
                  <p className="text-sm text-gray-800 leading-relaxed">
                    {memo.transcription}
                  </p>
                  
                  <div className="flex gap-2 mt-2 pt-2 border-t border-gray-100">
                    <button className="text-xs text-blue-600 hover:text-blue-800">
                      編集
                    </button>
                    <button className="text-xs text-red-600 hover:text-red-800">
                      削除
                    </button>
                    <button className="text-xs text-gray-600 hover:text-gray-800">
                      共有
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {memos.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <span className="text-3xl block mb-2">🎤</span>
                <p className="text-sm">まだ音声メモがありません</p>
              </div>
            )}
          </div>

          {/* クイックアクション */}
          <div className="space-y-2">
            <h3 className="text-sm font-semibold text-gray-700">⚡ クイックアクション</h3>
            <div className="grid grid-cols-2 gap-2">
              <button className="text-xs bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded transition-colors">
                📋 作業完了報告
              </button>
              <button className="text-xs bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded transition-colors">
                ⚠️ 問題報告
              </button>
              <button className="text-xs bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded transition-colors">
                📸 写真と併せて記録
              </button>
              <button className="text-xs bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded transition-colors">
                👥 チームに共有
              </button>
            </div>
          </div>
        </div>

        {/* フッター */}
        <div className="flex items-center justify-between p-6 border-t bg-gray-50">
          <div className="text-xs text-gray-500">
            音声は自動的に文字起こしされます
          </div>
          <button
            onClick={onClose}
            className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors"
          >
            完了
          </button>
        </div>
      </div>
    </div>
  )
}