import React, { useEffect, useState } from 'react'

const Countdown = ({ initialSeconds }) => {
  const [seconds, setSeconds] = useState(initialSeconds)

  useEffect(() => {
    if (seconds <= 0) {
      return
    }

    const intervalId = setInterval(() => {
      setSeconds((prevSeconds) => Math.max(prevSeconds - 1, 0))
    }, 1000)

    return () => {
      clearInterval(intervalId)
    }
  }, [seconds])

  return <span>{seconds}</span>
}

export default Countdown
