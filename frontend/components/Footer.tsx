'use client'

import React, { useState, useEffect } from 'react'

export default function Footer() {
  const [connectionStatus, setConnectionStatus] = useState<'online' | 'offline'>('online')
  const [lastSync, setLastSync] = useState<Date>(new Date())

  useEffect(() => {
    const interval = setInterval(() => {
      setLastSync(new Date())
    }, 30000) // 30秒ごとに更新

    return () => clearInterval(interval)
  }, [])

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('ja-JP', { 
      hour: '2-digit', 
      minute: '2-digit',
      second: '2-digit'
    })
  }

  return (
    <footer className="fixed bottom-0 left-0 right-0 bg-gray-50 border-t border-gray-200 px-4 py-2 z-30">
      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <div className={`w-2 h-2 rounded-full ${
              connectionStatus === 'online' ? 'bg-risk-ok' : 'bg-risk-alert'
            }`}></div>
            <span className={connectionStatus === 'online' ? 'text-risk-ok' : 'text-risk-alert'}>
              {connectionStatus === 'online' ? 'オンライン' : 'オフライン'}
            </span>
          </div>
          
          <div className="text-gray-600">
            最終同期: {formatTime(lastSync)}
          </div>
        </div>

        <div className="hidden md:block text-gray-500">
          Agri Partner AI v1.0
        </div>
      </div>
    </footer>
  )
}