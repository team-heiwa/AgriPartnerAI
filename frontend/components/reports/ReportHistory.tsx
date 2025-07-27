'use client'

import React, { useState } from 'react'

interface Report {
  id: string
  title: string
  type: 'weekly' | 'monthly' | 'custom'
  period: { start: Date; end: Date }
  format: 'pdf' | 'csv' | 'excel'
  status: 'generating' | 'completed' | 'failed'
  createdAt: Date
  fileSize?: string
  downloadCount: number
}

interface ReportHistoryProps {
  onReportSelect: (reportId: string) => void
}

export default function ReportHistory({ onReportSelect }: ReportHistoryProps) {
  const [sortBy, setSortBy] = useState<'date' | 'type' | 'status'>('date')
  const [filterStatus, setFilterStatus] = useState<'all' | 'generating' | 'completed' | 'failed'>('all')

  const [reports] = useState<Report[]>([
    {
      id: 'report_001',
      title: '週次レポート（1/8-1/14）',
      type: 'weekly',
      period: {
        start: new Date('2024-01-08'),
        end: new Date('2024-01-14')
      },
      format: 'pdf',
      status: 'completed',
      createdAt: new Date('2024-01-15T09:30:00'),
      fileSize: '2.3MB',
      downloadCount: 5
    },
    {
      id: 'report_002',
      title: '月次レポート（12月）',
      type: 'monthly',
      period: {
        start: new Date('2023-12-01'),
        end: new Date('2023-12-31')
      },
      format: 'pdf',
      status: 'completed',
      createdAt: new Date('2024-01-02T14:20:00'),
      fileSize: '8.7MB',
      downloadCount: 12
    },
    {
      id: 'report_003',
      title: 'カスタムレポート（害虫調査）',
      type: 'custom',
      period: {
        start: new Date('2024-01-10'),
        end: new Date('2024-01-15')
      },
      format: 'excel',
      status: 'generating',
      createdAt: new Date('2024-01-15T16:45:00'),
      downloadCount: 0
    },
    {
      id: 'report_004',
      title: 'データエクスポート（CSV）',
      type: 'custom',
      period: {
        start: new Date('2024-01-01'),
        end: new Date('2024-01-15')
      },
      format: 'csv',
      status: 'failed',
      createdAt: new Date('2024-01-15T11:15:00'),
      downloadCount: 0
    }
  ])

  const filteredReports = reports.filter(report => 
    filterStatus === 'all' || report.status === filterStatus
  )

  const sortedReports = [...filteredReports].sort((a, b) => {
    switch (sortBy) {
      case 'date':
        return b.createdAt.getTime() - a.createdAt.getTime()
      case 'type':
        return a.type.localeCompare(b.type)
      case 'status':
        return a.status.localeCompare(b.status)
      default:
        return 0
    }
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'generating': return 'bg-yellow-100 text-yellow-800'
      case 'completed': return 'bg-green-100 text-green-800'
      case 'failed': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'generating': return '生成中'
      case 'completed': return '完了'
      case 'failed': return '失敗'
      default: return status
    }
  }

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'weekly': return '週次'
      case 'monthly': return '月次'
      case 'custom': return 'カスタム'
      default: return type
    }
  }

  const getFormatIcon = (format: string) => {
    switch (format) {
      case 'pdf': return '📄'
      case 'csv': return '📊'
      case 'excel': return '📈'
      default: return '📁'
    }
  }

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('ja-JP', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatPeriod = (period: { start: Date; end: Date }) => {
    return `${period.start.toLocaleDateString('ja-JP', { month: 'short', day: 'numeric' })} - ${period.end.toLocaleDateString('ja-JP', { month: 'short', day: 'numeric' })}`
  }

  const handleDownload = (reportId: string, format: string) => {
    console.log(`Downloading report ${reportId} as ${format}`)
    // 実際のダウンロード処理
  }

  const handleDelete = (reportId: string) => {
    if (confirm('このレポートを削除しますか？')) {
      console.log(`Deleting report ${reportId}`)
      // 実際の削除処理
    }
  }

  const handleRegenerateReport = (reportId: string) => {
    console.log(`Regenerating report ${reportId}`)
    // 実際の再生成処理
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold text-gray-800">📋 レポート履歴</h2>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-600">並び順:</span>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as 'date' | 'type' | 'status')}
              className="text-sm border border-gray-300 rounded px-2 py-1"
            >
              <option value="date">作成日時</option>
              <option value="type">種類</option>
              <option value="status">ステータス</option>
            </select>
          </div>
          
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-600">フィルター:</span>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value as 'all' | 'generating' | 'completed' | 'failed')}
              className="text-sm border border-gray-300 rounded px-2 py-1"
            >
              <option value="all">すべて</option>
              <option value="completed">完了</option>
              <option value="generating">生成中</option>
              <option value="failed">失敗</option>
            </select>
          </div>
        </div>
      </div>

      {/* 統計サマリー */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-blue-600">{reports.length}</div>
          <div className="text-xs text-gray-600">総レポート数</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-green-600">{reports.filter(r => r.status === 'completed').length}</div>
          <div className="text-xs text-gray-600">完了</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-yellow-600">{reports.filter(r => r.status === 'generating').length}</div>
          <div className="text-xs text-gray-600">生成中</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-gray-600">
            {reports.reduce((sum, r) => sum + r.downloadCount, 0)}
          </div>
          <div className="text-xs text-gray-600">総ダウンロード数</div>
        </div>
      </div>

      {/* レポート一覧 */}
      <div className="space-y-3">
        {sortedReports.map((report) => (
          <div
            key={report.id}
            className="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-md transition-shadow"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3 mb-2">
                  <span className="text-xl">{getFormatIcon(report.format)}</span>
                  <h3 className="font-semibold text-gray-800">{report.title}</h3>
                  <span className={`text-xs px-2 py-1 rounded ${getStatusColor(report.status)}`}>
                    {getStatusLabel(report.status)}
                  </span>
                  <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                    {getTypeLabel(report.type)}
                  </span>
                </div>
                
                <div className="text-sm text-gray-600 space-y-1">
                  <div>📅 期間: {formatPeriod(report.period)}</div>
                  <div>🕒 作成: {formatDate(report.createdAt)}</div>
                  {report.fileSize && (
                    <div>📁 サイズ: {report.fileSize} • ダウンロード: {report.downloadCount}回</div>
                  )}
                </div>
              </div>

              <div className="flex items-center gap-2 ml-4">
                {report.status === 'completed' && (
                  <>
                    <button
                      onClick={() => handleDownload(report.id, report.format)}
                      className="text-sm bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700 transition-colors"
                    >
                      📥 ダウンロード
                    </button>
                    <button
                      onClick={() => onReportSelect(report.id)}
                      className="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded hover:bg-gray-200 transition-colors"
                    >
                      👁️ プレビュー
                    </button>
                  </>
                )}
                
                {report.status === 'generating' && (
                  <div className="flex items-center gap-2 text-sm text-yellow-600">
                    <div className="animate-spin w-4 h-4 border-2 border-yellow-600 border-t-transparent rounded-full"></div>
                    <span>生成中...</span>
                  </div>
                )}
                
                {report.status === 'failed' && (
                  <button
                    onClick={() => handleRegenerateReport(report.id)}
                    className="text-sm bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700 transition-colors"
                  >
                    🔄 再生成
                  </button>
                )}

                <div className="relative group">
                  <button className="text-gray-400 hover:text-gray-600 px-2 py-1">
                    ⋯
                  </button>
                  <div className="absolute right-0 mt-1 w-32 bg-white border border-gray-200 rounded-lg shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-10">
                    <button
                      onClick={() => onReportSelect(report.id)}
                      className="w-full text-left px-3 py-2 text-sm hover:bg-gray-50"
                    >
                      📝 編集
                    </button>
                    <button
                      onClick={() => handleDelete(report.id)}
                      className="w-full text-left px-3 py-2 text-sm text-red-600 hover:bg-red-50"
                    >
                      🗑️ 削除
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {sortedReports.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          <span className="text-4xl block mb-2">📄</span>
          <p>レポートがありません</p>
          <p className="text-sm mt-1">新しいレポートを生成してください</p>
        </div>
      )}
    </div>
  )
}